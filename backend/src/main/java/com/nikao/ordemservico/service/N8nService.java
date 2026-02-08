package com.nikao.ordemservico.service;

import com.nikao.ordemservico.domain.ChecklistExecution;
import com.nikao.ordemservico.domain.OrdemServico;
import com.nikao.ordemservico.domain.User;
import com.nikao.ordemservico.repository.UserRepository;
import com.nikao.ordemservico.service.push.ApnsPushService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
public class N8nService {

    @Value("${app.n8n.webhook-base:http://localhost:5678/webhook}")
    private String webhookBase;

    private final RestTemplate restTemplate = new RestTemplate();

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ApnsPushService apnsPushService;
    public void notifyExecutionFinalized(ChecklistExecution execution, OrdemServico ordem, User tecnico) {
        try {
            String url = webhookBase + "/checklist-finalizado";
            Map<String, Object> body = new HashMap<>();
            body.put("executionId", execution != null ? execution.getId() : null);
            body.put("orderId", ordem.getId());
            body.put("status", ordem.getStatus() != null ? ordem.getStatus().name() : null);
            body.put("technician", tecnico != null ? tecnico.getName() : null);
            body.put("technicianEmail", tecnico != null ? tecnico.getEmail() : null);
            if (ordem.getCriador() != null) {
                body.put("creator", ordem.getCriador().getName());
                body.put("creatorEmail", ordem.getCriador().getEmail());
                body.put("creatorFcmToken", ordem.getCriador().getFcmToken());
            }
            if (ordem.getEquipamento() != null) {
                body.put("equipment", ordem.getEquipamento().getNome());
                body.put("equipmentCode", ordem.getEquipamento().getCodigo());
            }
            if (ordem.getCliente() != null) {
                body.put("client", ordem.getCliente().getNome());
            }
            if (execution != null) {
                body.put("reportUrl", execution.getReportUrl());
                body.put("reportHash", execution.getReportHash());
                body.put("finishedAt", execution.getFinishedAt() != null ? execution.getFinishedAt().toString() : null);
            }

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            restTemplate.postForEntity(url, new HttpEntity<>(body, headers), String.class);
        } catch (Exception ignored) {
            // Avoid failing execution on notification issues.
        }
    }

    public void notifyOrderAssigned(OrdemServico ordem) {
        try {
            if (ordem == null) return;
            User creator = resolveUser(ordem.getCriador());
            User technician = resolveUser(ordem.getResponsavel());
            if (technician == null) return;
            boolean hasFcm = !isBlank(technician.getFcmToken());
            boolean hasApns = !isBlank(technician.getApnsToken());
            if (!hasFcm && !hasApns) return;
            if (creator != null
                    && creator.getId() != null
                    && technician.getId() != null
                    && creator.getId().equals(technician.getId())) {
                return;
            }

            String url = webhookBase + "/ordem-atribuida";
            Map<String, Object> body = new HashMap<>();
            body.put("orderId", ordem.getId());
            body.put("status", ordem.getStatus() != null ? ordem.getStatus().name() : null);
            body.put("priority", ordem.getPrioridade());
            body.put("orderType", ordem.getTipo() != null ? ordem.getTipo().name() : null);
            body.put("scheduledFor", ordem.getDataPrevista() != null ? ordem.getDataPrevista().toString() : null);
            body.put("createdAt", ordem.getDataCriacao() != null ? ordem.getDataCriacao().toString() : null);

            body.put("technicianId", technician.getId());
            body.put("technician", technician.getName());
            body.put("technicianEmail", technician.getEmail());
            body.put("technicianFcmToken", technician.getFcmToken());
            body.put("technicianApnsToken", technician.getApnsToken());

            if (creator != null) {
                body.put("creatorId", creator.getId());
                body.put("creator", creator.getName());
                body.put("creatorEmail", creator.getEmail());
            }
            if (ordem.getEquipamento() != null) {
                body.put("equipment", ordem.getEquipamento().getNome());
                body.put("equipmentCode", ordem.getEquipamento().getCodigo());
                body.put("equipmentLocation", ordem.getEquipamento().getLocalizacao());
            }
            if (ordem.getCliente() != null) {
                body.put("client", ordem.getCliente().getNome());
            }

            if (hasApns) {
                String title = "Nova ordem atribuida";
                String message = "Ordem #" + ordem.getId() + " atribuida";
                if (creator != null && !isBlank(creator.getName())) {
                    message = "Ordem #" + ordem.getId() + " atribuida por " + creator.getName();
                }
                apnsPushService.sendNotification(
                        technician.getApnsToken(),
                        title,
                        message,
                        Map.of(
                                "orderId", String.valueOf(ordem.getId()),
                                "status", ordem.getStatus() != null ? ordem.getStatus().name() : "",
                                "priority", ordem.getPrioridade() != null ? ordem.getPrioridade() : "",
                                "orderType", ordem.getTipo() != null ? ordem.getTipo().name() : ""
                        )
                );
            }
            if (hasFcm) {
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_JSON);
                restTemplate.postForEntity(url, new HttpEntity<>(body, headers), String.class);
            }
        } catch (Exception ignored) {
            // Avoid failing order creation on notification issues.
        }
    }

    public void notifyTestPush(User user, String title, String bodyText) {
        try {
            User resolved = resolveUser(user);
            if (resolved == null) return;
            boolean hasFcm = !isBlank(resolved.getFcmToken());
            boolean hasApns = !isBlank(resolved.getApnsToken());
            if (!hasFcm && !hasApns) return;

            String url = webhookBase + "/push-test";
            Map<String, Object> body = new HashMap<>();
            body.put("userId", resolved.getId());
            body.put("userEmail", resolved.getEmail());
            body.put("title", isBlank(title) ? "Teste de notificacao" : title);
            body.put("message", isBlank(bodyText) ? "Push de teste" : bodyText);
            body.put("fcmToken", resolved.getFcmToken());
            body.put("apnsToken", resolved.getApnsToken());

            if (hasApns) {
                apnsPushService.sendNotification(
                        resolved.getApnsToken(),
                        isBlank(title) ? "Teste de notificacao" : title,
                        isBlank(bodyText) ? "Push de teste" : bodyText,
                        Map.of("test", "true", "userId", String.valueOf(resolved.getId()))
                );
            }
            if (hasFcm) {
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_JSON);
                restTemplate.postForEntity(url, new HttpEntity<>(body, headers), String.class);
            }
        } catch (Exception ignored) {
            // Avoid failing API on notification issues.
        }
    }

    private User resolveUser(User user) {
        if (user == null) return null;
        if (user.getId() == null) return user;
        if (user.getFcmToken() != null || user.getApnsToken() != null || user.getName() != null) {
            return user;
        }
        return userRepository.findById(user.getId()).orElse(user);
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
