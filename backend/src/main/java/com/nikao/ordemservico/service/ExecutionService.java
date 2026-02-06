package com.nikao.ordemservico.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nikao.ordemservico.domain.*;
import com.nikao.ordemservico.dto.*;
import com.nikao.ordemservico.repository.*;
import com.nikao.ordemservico.realtime.OrderRealtimeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.HexFormat;
import java.util.List;

@Service
public class ExecutionService {

    @Autowired
    private OrdemServicoRepository ordemServicoRepository;

    @Autowired
    private EquipamentoRepository equipamentoRepository;

    @Autowired
    private ChecklistExecutionRepository checklistExecutionRepository;

    @Autowired
    private ChecklistExecutionItemRepository checklistExecutionItemRepository;

    @Autowired
    private EvidenceRepository evidenceRepository;

    @Autowired
    private ExecutionPhotoRepository executionPhotoRepository;

    @Autowired
    private AuditLogRepository auditLogRepository;

    @Autowired
    private UserDeviceRepository userDeviceRepository;

    @Autowired
    private ReportService reportService;

    @Autowired
    private StorageService storageService;

    @Autowired
    private CurrentUserService currentUserService;

    @Autowired
    private N8nService n8nService;

    @Autowired
    private AssinaturaRepository assinaturaRepository;

    @Autowired
    private OrderRealtimeService orderRealtimeService;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Transactional
    public ExecutionStartResponse startExecution(ExecutionStartRequest request) {
        User user = currentUserService.getCurrentUser();
        OrdemServico ordem = ordemServicoRepository.findById(request.getMaintenanceOrderId()).orElseThrow();

        if (ordem.getCompany() == null || user.getCompany() == null
                || !ordem.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Ordem nao pertence a empresa do usuario");
        }

        TipoOrdem tipo = ordem.getTipo() != null ? ordem.getTipo() : TipoOrdem.MANUTENCAO;

        Equipamento equipamento = ordem.getEquipamento();
        if (tipo == TipoOrdem.MANUTENCAO && equipamento == null) {
            throw new IllegalStateException("Equipamento obrigatorio para manutencao");
        }

        if (tipo == TipoOrdem.MANUTENCAO && equipamento != null) {
            if (request.getQrCodePayload() == null || request.getQrCodePayload().isBlank()) {
                throw new IllegalStateException("QR Code obrigatorio para manutencao");
            }
            Long equipmentIdFromQr = extractEquipmentId(request.getQrCodePayload());
            if (equipmentIdFromQr == null || !equipmentIdFromQr.equals(equipamento.getId())) {
                throw new IllegalStateException("QR Code nao corresponde ao equipamento da ordem");
            }
        }

        if (ordem.getStatus() != null && ordem.getStatus().name().equals("FINALIZADA")) {
            throw new IllegalStateException("Ordem ja finalizada");
        }

        if (ordem.getResponsavel() != null && !ordem.getResponsavel().getId().equals(user.getId())) {
            throw new IllegalStateException("Tecnico nao autorizado para esta ordem");
        }

        if (tipo == TipoOrdem.MANUTENCAO) {
            if (ordem.getChecklist() == null || ordem.getChecklist().getItens() == null) {
                throw new IllegalStateException("Checklist nao configurado para esta ordem");
            }
        }

        String deviceId = request.getDeviceId();
        if (deviceId == null || deviceId.isBlank()) {
            deviceId = "unknown-" + user.getId() + "-" + System.currentTimeMillis();
        }
        ensureDeviceBinding(user, deviceId);

        boolean geofenceOk = true;
        if (equipamento != null) {
            geofenceOk = isWithinGeofence(
                    equipamento.getLatitude(),
                    equipamento.getLongitude(),
                    request.getLatitude(),
                    request.getLongitude(),
                    equipamento.getGeofenceRadiusM()
            );
        }
        if (!geofenceOk) {
            throw new IllegalStateException("Fora da geofence do equipamento");
        }

        ChecklistExecution execution = new ChecklistExecution();
        execution.setCompany(ordem.getCompany());
        execution.setOrdemServico(ordem);
        execution.setEquipamento(equipamento);
        execution.setTecnico(user);
        execution.setDeviceId(deviceId);
        execution.setGeoLat(request.getLatitude());
        execution.setGeoLng(request.getLongitude());
        execution.setGeoAccuracy(request.getAccuracy());
        execution.setGeofenceOk(geofenceOk);
        execution.setStatus("IN_PROGRESS");
        execution.setStartedAt(LocalDateTime.now());

        checklistExecutionRepository.save(execution);

        if (ordem.getResponsavel() == null) {
            ordem.setResponsavel(user);
        }
        ordem.setStatus(StatusOrdem.EM_ANDAMENTO);
        ordemServicoRepository.save(ordem);

        audit("EXECUTION_STARTED", "checklist_execution", execution.getId().toString(), user, ordem.getCompany(), request.getDeviceId());

        ExecutionStartResponse response = new ExecutionStartResponse();
        response.setExecutionId(execution.getId());
        response.setMaintenanceOrderId(ordem.getId());
        response.setEquipmentId(equipamento != null ? equipamento.getId() : null);
        response.setChecklistItems(
                tipo == TipoOrdem.MANUTENCAO && ordem.getChecklist() != null
                        ? ordem.getChecklist().getItens()
                        : List.of()
        );
        response.setOrderType(tipo.name());
        response.setProblemDescription(ordem.getProblemDescription());
        return response;
    }

    @Transactional(readOnly = true)
    public ExecutionLookupResponse lookupExecution(ExecutionLookupRequest request) {
        User user = currentUserService.getCurrentUser();
        Equipamento equipamento = resolveEquipment(user, request);
        OrdemServico ordem = findOpenOrder(equipamento, user);
        String payload = buildQrPayload(equipamento, request.getQrCodePayload());
        return new ExecutionLookupResponse(
                ordem.getId(),
                ordem.getStatus() != null ? ordem.getStatus().name() : null,
                equipamento.getId(),
                equipamento.getNome(),
                equipamento.getCodigo(),
                ordem.getCliente() != null ? ordem.getCliente().getNome() : null,
                ordem.getDataPrevista() != null ? ordem.getDataPrevista().toString() : null,
                payload
        );
    }

    @Transactional
    public ChecklistExecutionItem recordItem(Long executionId, ExecutionItemRequest request) {
        User user = currentUserService.getCurrentUser();
        ChecklistExecution execution = checklistExecutionRepository.findById(executionId).orElseThrow();
        ensureNotFinalized(execution);
        if (!execution.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Execucao fora da empresa do usuario");
        }
        if (!execution.getTecnico().getId().equals(user.getId())) {
            throw new IllegalStateException("Tecnico nao autorizado para registrar itens");
        }
        if (!execution.getTecnico().getId().equals(user.getId())) {
            throw new IllegalStateException("Tecnico nao autorizado para finalizar esta execucao");
        }

        TipoOrdem tipo = execution.getOrdemServico().getTipo() != null
                ? execution.getOrdemServico().getTipo()
                : TipoOrdem.MANUTENCAO;
        if (tipo != TipoOrdem.MANUTENCAO) {
            throw new IllegalStateException("Itens de checklist nao se aplicam a esta ordem");
        }

        ChecklistItem item = execution.getOrdemServico().getChecklist().getItens().stream()
                .filter(ci -> ci.getId().equals(request.getChecklistItemId()))
                .findFirst()
                .orElseThrow();

        ChecklistExecutionItem execItem = checklistExecutionItemRepository
                .findByChecklistExecutionIdAndChecklistItemId(executionId, request.getChecklistItemId())
                .orElseGet(ChecklistExecutionItem::new);
        execItem.setChecklistExecution(execution);
        execItem.setChecklistItem(item);
        execItem.setStatus(request.getStatus());
        execItem.setObservation(request.getObservation());
        execItem.setEvidenceRequired(item.isObrigatorioFoto());
        execItem.setPerformedAt(LocalDateTime.now());

        ChecklistExecutionItem saved = checklistExecutionItemRepository.save(execItem);

        audit("EXECUTION_ITEM_RECORDED", "checklist_execution_item", saved.getId().toString(), execution.getTecnico(), execution.getCompany(), execution.getDeviceId());

        return saved;
    }

    @Transactional
    public Evidence addEvidence(EvidenceRequest request) {
        User user = currentUserService.getCurrentUser();
        ChecklistExecutionItem execItem = checklistExecutionItemRepository.findById(request.getChecklistExecutionItemId()).orElseThrow();
        ensureNotFinalized(execItem.getChecklistExecution());
        if (!execItem.getChecklistExecution().getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Evidencia fora da empresa do usuario");
        }
        if (!execItem.getChecklistExecution().getTecnico().getId().equals(user.getId())) {
            throw new IllegalStateException("Tecnico nao autorizado para anexar evidencias");
        }

        Evidence evidence = new Evidence();
        evidence.setChecklistExecutionItem(execItem);
        evidence.setUrl(request.getUrl());
        evidence.setHashSha256(request.getHashSha256());
        evidence.setMimeType(request.getMimeType());
        evidence.setSizeBytes(request.getSizeBytes());

        Evidence saved = evidenceRepository.save(evidence);
        ChecklistExecution execution = execItem.getChecklistExecution();
        audit("EVIDENCE_ATTACHED", "evidence", saved.getId().toString(), execution.getTecnico(), execution.getCompany(), execution.getDeviceId());
        return saved;
    }

    @Transactional
    public Evidence uploadEvidence(Long checklistExecutionItemId, MultipartFile file) {
        User user = currentUserService.getCurrentUser();
        ChecklistExecutionItem execItem = checklistExecutionItemRepository.findById(checklistExecutionItemId).orElseThrow();
        ensureNotFinalized(execItem.getChecklistExecution());
        ChecklistExecution execution = execItem.getChecklistExecution();
        if (!execution.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Evidencia fora da empresa do usuario");
        }
        if (!execution.getTecnico().getId().equals(user.getId())) {
            throw new IllegalStateException("Tecnico nao autorizado para anexar evidencias");
        }

        try {
            byte[] bytes = file.getBytes();
            String hash = sha256Bytes(bytes);
            String sanitizedName = file.getOriginalFilename() == null ? "evidence" : file.getOriginalFilename().replaceAll("[^a-zA-Z0-9._-]", "_");
            String path = "evidences/company-" + execution.getCompany().getId()
                    + "/execution-" + execution.getId()
                    + "/item-" + execItem.getId()
                    + "/" + System.currentTimeMillis() + "-" + sanitizedName;

            String storedPath = storageService.store(bytes, path);

            Evidence evidence = new Evidence();
            evidence.setChecklistExecutionItem(execItem);
            evidence.setUrl(storedPath);
            evidence.setHashSha256(hash);
            evidence.setMimeType(file.getContentType());
            evidence.setSizeBytes(file.getSize());

            Evidence saved = evidenceRepository.save(evidence);
            audit("EVIDENCE_UPLOADED", "evidence", saved.getId().toString(), execution.getTecnico(), execution.getCompany(), execution.getDeviceId());
            return saved;
        } catch (Exception e) {
            throw new IllegalStateException("Falha ao anexar evidencia", e);
        }
    }

    @Transactional
    public ExecutionPhoto uploadExecutionPhoto(Long executionId, MultipartFile file) {
        User user = currentUserService.getCurrentUser();
        ChecklistExecution execution = checklistExecutionRepository.findById(executionId).orElseThrow();
        ensureNotFinalized(execution);
        if (!execution.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Execucao fora da empresa do usuario");
        }
        if (!execution.getTecnico().getId().equals(user.getId())) {
            throw new IllegalStateException("Tecnico nao autorizado para anexar fotos");
        }

        try {
            byte[] bytes = file.getBytes();
            String hash = sha256Bytes(bytes);
            String sanitizedName = file.getOriginalFilename() == null ? "photo" : file.getOriginalFilename().replaceAll("[^a-zA-Z0-9._-]", "_");
            String path = "execution-photos/company-" + execution.getCompany().getId()
                    + "/execution-" + execution.getId()
                    + "/" + System.currentTimeMillis() + "-" + sanitizedName;

            String storedPath = storageService.store(bytes, path);

            ExecutionPhoto photo = new ExecutionPhoto();
            photo.setExecution(execution);
            photo.setUrl(storedPath);
            photo.setHashSha256(hash);
            photo.setMimeType(file.getContentType());
            photo.setSizeBytes(file.getSize());

            return executionPhotoRepository.save(photo);
        } catch (Exception e) {
            throw new IllegalStateException("Falha ao anexar foto", e);
        }
    }

    @Transactional
    public ChecklistExecution finalizeExecution(Long executionId, ExecutionFinalizeRequest request) {
        User user = currentUserService.getCurrentUser();
        ChecklistExecution execution = checklistExecutionRepository.findByIdForUpdate(executionId).orElseThrow();
        if (execution.getFinishedAt() != null || "FINALIZED".equals(execution.getStatus())) {
            return execution;
        }
        if (!execution.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Execucao fora da empresa do usuario");
        }

        TipoOrdem tipo = execution.getOrdemServico().getTipo() != null
                ? execution.getOrdemServico().getTipo()
                : TipoOrdem.MANUTENCAO;
        List<ChecklistExecutionItem> recordedItems = checklistExecutionItemRepository.findByChecklistExecutionId(executionId);
        if (tipo == TipoOrdem.MANUTENCAO) {
            List<ChecklistItem> templateItems = execution.getOrdemServico().getChecklist().getItens();
            if (recordedItems.size() < templateItems.size()) {
                throw new IllegalStateException("Checklist incompleto");
            }

            for (ChecklistExecutionItem item : recordedItems) {
                if (item.isEvidenceRequired()) {
                    long evidenceCount = evidenceRepository.countByChecklistExecutionItemId(item.getId());
                    if (evidenceCount == 0) {
                        throw new IllegalStateException("Evidencia obrigatoria ausente");
                    }
                }
            }
        } else {
            if (request.getFinalObservation() == null || request.getFinalObservation().isBlank()) {
                throw new IllegalStateException("Descricao do servico obrigatoria");
            }
        }

        LocalDateTime finishedAt = LocalDateTime.now();
        String signatureHash = sha256(request.getSignatureBase64());
        String integrityHash = buildIntegrityHash(execution, recordedItems, signatureHash, finishedAt);

        Assinatura assinatura = new Assinatura();
        assinatura.setChecklistExecution(execution);
        assinatura.setTecnico(execution.getTecnico());
        assinatura.setAssinaturaBase64(request.getSignatureBase64());
        assinatura.setSignatureHash(signatureHash);
        assinatura.setDataAssinatura(finishedAt);
        assinaturaRepository.save(assinatura);

        byte[] reportBytes = reportService.buildExecutionReport(execution, request.getFinalObservation(), assinatura);
        String reportPath = storageService.store(reportBytes, buildReportPath(execution));
        String reportHash = sha256Bytes(reportBytes);

        int updated = checklistExecutionRepository.finalizeExecutionIfNotFinalized(
                execution.getId(),
                finishedAt,
                request.getFinalObservation(),
                integrityHash,
                reportPath,
                reportHash
        );
        if (updated == 0) {
            return execution;
        }

        OrdemServico ordem = execution.getOrdemServico();
        ordem.setStatus(StatusOrdem.FINALIZADA);
        ordem.setDataFinalizacao(LocalDateTime.now());
        OrdemServico savedOrdem = ordemServicoRepository.save(ordem);
        orderRealtimeService.broadcastOrderUpdate(savedOrdem);

        audit("EXECUTION_FINALIZED", "checklist_execution", execution.getId().toString(), execution.getTecnico(), execution.getCompany(), execution.getDeviceId());

        n8nService.notifyExecutionFinalized(execution, ordem, execution.getTecnico());

        return execution;
    }

    private boolean isAlreadyFinalizedException(RuntimeException ex) {
        Throwable current = ex;
        while (current != null) {
            String message = current.getMessage();
            if (message != null && message.contains("finalized cannot be modified")) {
                return true;
            }
            current = current.getCause();
        }
        return false;
    }

    private String buildReportPath(ChecklistExecution execution) {
        return "reports/company-" + execution.getCompany().getId()
                + "/execution-" + execution.getId() + ".pdf";
    }

    private void ensureDeviceBinding(User user, String deviceId) {
        List<UserDevice> activeDevices = userDeviceRepository.findByUserIdAndActiveTrue(user.getId());
        boolean hasDevice = activeDevices.stream().anyMatch(d -> d.getDeviceId().equals(deviceId));
        if (!activeDevices.isEmpty() && !hasDevice) {
            throw new IllegalStateException("Dispositivo nao autorizado para este usuario");
        }
        if (!hasDevice) {
            UserDevice device = new UserDevice();
            device.setUser(user);
            device.setDeviceId(deviceId);
            device.setActive(true);
            userDeviceRepository.save(device);
        }
    }

    private void ensureNotFinalized(ChecklistExecution execution) {
        if (execution.getFinishedAt() != null || "FINALIZED".equals(execution.getStatus())) {
            throw new IllegalStateException("Execucao ja finalizada");
        }
    }

    private Long extractEquipmentId(String qrCodePayload) {
        try {
            JsonNode node = objectMapper.readTree(qrCodePayload);
            if (node.has("id")) {
                return node.get("id").asLong();
            }
        } catch (Exception ignored) {
        }
        return null;
    }

    private Equipamento resolveEquipment(User user, ExecutionLookupRequest request) {
        if (request.getQrCodePayload() != null && !request.getQrCodePayload().isEmpty()) {
            Long equipmentId = extractEquipmentId(request.getQrCodePayload());
            if (equipmentId != null) {
                Equipamento equipamento = equipamentoRepository.findById(equipmentId)
                        .orElseThrow(() -> new IllegalStateException("Equipamento nao encontrado"));
                ensureSameCompany(user, equipamento);
                return equipamento;
            }

            Equipamento byQr = equipamentoRepository
                    .findByQrCodeAndCompanyId(request.getQrCodePayload(), user.getCompany().getId())
                    .orElseThrow(() -> new IllegalStateException("QR Code nao reconhecido"));
            return byQr;
        }

        if (request.getEquipmentCode() == null || request.getEquipmentCode().isBlank()) {
            throw new IllegalStateException("Codigo do equipamento obrigatorio");
        }

        return equipamentoRepository
                .findByCodigoAndCompanyId(request.getEquipmentCode().trim(), user.getCompany().getId())
                .orElseThrow(() -> new IllegalStateException("Equipamento nao encontrado"));
    }

    private OrdemServico findOpenOrder(Equipamento equipamento, User user) {
        OrdemServico ordem = ordemServicoRepository
                .findFirstByEquipamentoIdAndStatusInOrderByDataPrevistaAsc(
                        equipamento.getId(),
                        List.of(StatusOrdem.ABERTA, StatusOrdem.EM_ANDAMENTO, StatusOrdem.ATRASADA)
                )
                .orElseThrow(() -> new IllegalStateException("Nenhuma ordem aberta para este equipamento"));

        if (ordem.getCompany() == null || !ordem.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Ordem nao pertence a empresa do usuario");
        }
        return ordem;
    }

    private void ensureSameCompany(User user, Equipamento equipamento) {
        if (equipamento.getCompany() == null || user.getCompany() == null ||
                !equipamento.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Equipamento nao pertence a empresa do usuario");
        }
    }

    private String buildQrPayload(Equipamento equipamento, String provided) {
        if (provided != null && !provided.isBlank()) {
            return provided;
        }
        try {
            return objectMapper.writeValueAsString(
                    objectMapper.createObjectNode()
                            .put("id", equipamento.getId())
                            .put("nome", equipamento.getNome())
                            .put("serial", equipamento.getNumeroSerie())
                            .put("generatedAt", java.time.LocalDateTime.now().toString())
            );
        } catch (Exception e) {
            return "{\"id\":" + equipamento.getId() + "}";
        }
    }

    private boolean isWithinGeofence(Double refLat, Double refLng, Double lat, Double lng, Integer radiusMeters) {
        if (refLat == null || refLng == null || lat == null || lng == null || radiusMeters == null) {
            return false;
        }
        double distance = haversineMeters(refLat, refLng, lat, lng);
        return distance <= radiusMeters;
    }

    private double haversineMeters(double lat1, double lon1, double lat2, double lon2) {
        final double R = 6371000.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    private String buildIntegrityHash(ChecklistExecution execution, List<ChecklistExecutionItem> items, String signatureHash, LocalDateTime finishedAt) {
        StringBuilder sb = new StringBuilder();
        sb.append("execution:").append(execution.getId()).append("|");
        sb.append("order:").append(execution.getOrdemServico().getId()).append("|");
        sb.append("equipment:")
                .append(execution.getEquipamento() != null ? execution.getEquipamento().getId() : "-")
                .append("|");
        sb.append("technician:").append(execution.getTecnico().getId()).append("|");
        sb.append("started:").append(execution.getStartedAt()).append("|");
        sb.append("finished:").append(finishedAt).append("|");
        sb.append("signature:").append(signatureHash).append("|");

        items.stream()
                .sorted(Comparator.comparing(i -> i.getChecklistItem().getId()))
                .forEach(item -> {
                    sb.append("item:").append(item.getChecklistItem().getId()).append("|");
                    sb.append("status:").append(item.isStatus()).append("|");
                    sb.append("obs:").append(item.getObservation()).append("|");
                    evidenceRepository.findByChecklistExecutionItemId(item.getId()).stream()
                            .sorted(Comparator.comparing(Evidence::getId))
                            .forEach(e -> {
                                sb.append("evidence:").append(e.getId()).append("|");
                                sb.append("hash:").append(e.getHashSha256()).append("|");
                                sb.append("url:").append(e.getUrl()).append("|");
                            });
                });

        return sha256(sb.toString());
    }

    private String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(value.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (Exception e) {
            throw new IllegalStateException("Nao foi possivel gerar hash", e);
        }
    }

    private String sha256Bytes(byte[] value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(value);
            return HexFormat.of().formatHex(hash);
        } catch (Exception e) {
            throw new IllegalStateException("Nao foi possivel gerar hash", e);
        }
    }

    private void audit(String action, String entity, String entityId, User actor, Company company, String deviceId) {
        AuditLog log = new AuditLog();
        log.setAction(action);
        log.setEntity(entity);
        log.setEntityId(entityId);
        log.setActor(actor);
        log.setCompany(company);
        log.setDeviceId(deviceId);
        auditLogRepository.save(log);
    }
}
