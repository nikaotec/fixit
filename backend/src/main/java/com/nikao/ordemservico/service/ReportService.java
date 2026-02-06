package com.nikao.ordemservico.service;

import com.lowagie.text.*;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.nikao.ordemservico.domain.*;
import com.nikao.ordemservico.repository.ChecklistExecutionItemRepository;
import com.nikao.ordemservico.repository.EvidenceRepository;
import com.nikao.ordemservico.repository.ExecutionPhotoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Base64;
import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class ReportService {

    @Autowired
    private ChecklistExecutionItemRepository checklistExecutionItemRepository;

    @Autowired
    private EvidenceRepository evidenceRepository;

    @Autowired
    private ExecutionPhotoRepository executionPhotoRepository;

    @Autowired
    private StorageService storageService;

    public byte[] buildExecutionReport(ChecklistExecution execution) {
        return buildExecutionReport(execution, execution.getFinalObservation(), execution.getAssinatura());
    }

    public byte[] buildExecutionReport(ChecklistExecution execution, String finalObservationOverride, Assinatura signatureOverride) {
        try {
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            Document document = new Document(PageSize.A4, 36, 36, 36, 36);
            PdfWriter.getInstance(document, output);
            document.open();

            Font titleFont = new Font(Font.HELVETICA, 16, Font.BOLD);
            Font sectionFont = new Font(Font.HELVETICA, 12, Font.BOLD);
            Font bodyFont = new Font(Font.HELVETICA, 10, Font.NORMAL);

            OrdemServico ordem = execution.getOrdemServico();
            TipoOrdem tipo = ordem.getTipo() != null ? ordem.getTipo() : TipoOrdem.MANUTENCAO;
            String reportTitle = tipo == TipoOrdem.MANUTENCAO
                    ? "Fixit - Relatorio de Manutencao"
                    : "Fixit - Relatorio de Servico";
            document.add(new Paragraph(reportTitle, titleFont));
            document.add(new Paragraph("Execucao #" + execution.getId(), bodyFont));
            document.add(new Paragraph(" "));

            addSection(document, "Equipamento", sectionFont);
            Equipamento eq = execution.getEquipamento();
            document.add(new Paragraph("Nome: " + safe(eq != null ? eq.getNome() : null), bodyFont));
            document.add(new Paragraph("Fabricante/Modelo: " + safe(eq != null ? eq.getFabricante() : null) + " / " + safe(eq != null ? eq.getModelo() : null), bodyFont));
            document.add(new Paragraph("Serie: " + safe(eq != null ? eq.getNumeroSerie() : null) + " | Classe Risco: " + safe(eq != null ? eq.getClasseRisco() : null), bodyFont));
            document.add(new Paragraph("Localizacao: " + safe(eq != null ? eq.getLocalizacao() : null), bodyFont));
            document.add(new Paragraph(" "));

            addSection(document, "Ordem de Servico", sectionFont);
            document.add(new Paragraph("Ordem: " + ordem.getId(), bodyFont));
            document.add(new Paragraph("Status: " + safe(ordem.getStatus()), bodyFont));
            document.add(new Paragraph("Tipo: " + safe(tipoLabel(tipo)), bodyFont));
            if (ordem.getProblemDescription() != null && !ordem.getProblemDescription().isBlank()) {
                document.add(new Paragraph("Problema informado: " + safe(ordem.getProblemDescription()), bodyFont));
            }
            if (ordem.getEquipmentBrand() != null && !ordem.getEquipmentBrand().isBlank()) {
                document.add(new Paragraph("Marca: " + safe(ordem.getEquipmentBrand()), bodyFont));
            }
            if (ordem.getEquipmentModel() != null && !ordem.getEquipmentModel().isBlank()) {
                document.add(new Paragraph("Modelo: " + safe(ordem.getEquipmentModel()), bodyFont));
            }
            document.add(new Paragraph("Agendada: " + formatDate(ordem.getDataPrevista()), bodyFont));
            document.add(new Paragraph("Finalizada: " + formatDate(ordem.getDataFinalizacao()), bodyFont));
            document.add(new Paragraph(" "));

            addSection(document, "Execucao", sectionFont);
            document.add(new Paragraph("Tecnico: " + safe(execution.getTecnico().getName()), bodyFont));
            document.add(new Paragraph("Inicio: " + formatDate(execution.getStartedAt()), bodyFont));
            document.add(new Paragraph("Fim: " + formatDate(execution.getFinishedAt()), bodyFont));
            document.add(new Paragraph("Geolocalizacao: " + safe(execution.getGeoLat()) + ", " + safe(execution.getGeoLng()), bodyFont));
            document.add(new Paragraph("Geofence OK: " + (execution.isGeofenceOk() ? "SIM" : "NAO"), bodyFont));
            document.add(new Paragraph("Device ID: " + safe(execution.getDeviceId()), bodyFont));
            String finalObservation = finalObservationOverride != null ? finalObservationOverride : execution.getFinalObservation();
            document.add(new Paragraph("Observacao final: " + safe(finalObservation), bodyFont));
            document.add(new Paragraph(" "));

            List<ChecklistExecutionItem> items = checklistExecutionItemRepository.findByChecklistExecutionId(execution.getId());
            if (tipo == TipoOrdem.MANUTENCAO) {
                addSection(document, "Checklist", sectionFont);
                PdfPTable table = new PdfPTable(4);
                table.setWidthPercentage(100f);
                table.addCell("Item");
                table.addCell("Status");
                table.addCell("Observacao");
                table.addCell("Evidencias");

                for (ChecklistExecutionItem item : items) {
                    table.addCell(safe(item.getChecklistItem().getDescricao()));
                    table.addCell(item.isStatus() ? "Conforme" : "Nao conforme");
                    table.addCell(safe(item.getObservation()));
                    long evidenceCount = evidenceRepository.countByChecklistExecutionItemId(item.getId());
                    table.addCell(String.valueOf(evidenceCount));
                }
                document.add(table);
                document.add(new Paragraph(" "));

                addSection(document, "Evidencias por Item", sectionFont);
                addItemEvidences(document, items);
                document.add(new Paragraph(" "));
            } else {
                addSection(document, "Servico executado", sectionFont);
                document.add(new Paragraph("Descricao: " + safe(finalObservation), bodyFont));
                document.add(new Paragraph(" "));
            }

            Assinatura signature = signatureOverride != null ? signatureOverride : execution.getAssinatura();
            addSection(document, "Assinatura", sectionFont);
            document.add(new Paragraph("Hash da assinatura: " + safe(signature != null ? signature.getSignatureHash() : null), bodyFont));
            document.add(new Paragraph("Assinada em: " + formatDate(signature != null ? signature.getDataAssinatura() : null), bodyFont));
            addSignatureImage(document, signature);
            document.add(new Paragraph(" "));

            addSection(document, "Fotos da Execucao", sectionFont);
            addExecutionPhotos(document, execution);
            document.add(new Paragraph(" "));

            addSection(document, "Integridade", sectionFont);
            document.add(new Paragraph("Hash de integridade: " + safe(execution.getIntegrityHash()), bodyFont));

            document.close();
            return output.toByteArray();
        } catch (Exception e) {
            throw new IllegalStateException("Falha ao gerar PDF", e);
        }
    }

    private void addSection(Document document, String title, Font font) throws DocumentException {
        document.add(new Paragraph(title, font));
    }

    private String formatDate(java.time.LocalDateTime dateTime) {
        if (dateTime == null) return "-";
        return dateTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    private String safe(Object value) {
        return value == null ? "-" : value.toString();
    }

    private void addSignatureImage(Document document, Assinatura signature) {
        try {
            String base64 = signature != null ? signature.getAssinaturaBase64() : null;
            if (base64 == null || base64.isBlank()) return;
            byte[] imageBytes = decodeBase64Image(base64);
            Image image = Image.getInstance(imageBytes);
            image.scaleToFit(240, 120);
            document.add(image);
        } catch (Exception ignored) {
        }
    }

    private void addExecutionPhotos(Document document, ChecklistExecution execution) {
        try {
            List<ExecutionPhoto> photos = executionPhotoRepository.findByExecutionId(execution.getId());
            if (photos.isEmpty()) {
                document.add(new Paragraph("Nenhuma foto anexada.", new Font(Font.HELVETICA, 10, Font.NORMAL)));
                return;
            }
            for (ExecutionPhoto photo : photos) {
                try {
                    if (photo.getMimeType() != null && photo.getMimeType().startsWith("image")) {
                        byte[] bytes = storageService.read(photo.getUrl());
                        Image image = Image.getInstance(bytes);
                        image.scaleToFit(360, 240);
                        document.add(image);
                        document.add(new Paragraph(" "));
                    } else {
                        document.add(new Paragraph("Midia: " + safe(photo.getUrl()), new Font(Font.HELVETICA, 10, Font.NORMAL)));
                        document.add(new Paragraph(" "));
                    }
                } catch (Exception ignored) {
                }
            }
        } catch (Exception ignored) {
        }
    }

    private String tipoLabel(TipoOrdem tipo) {
        if (tipo == null) return "Manutencao";
        return switch (tipo) {
            case MANUTENCAO -> "Manutencao";
            case CONSERTO -> "Conserto";
            case OUTROS -> "Outros";
        };
    }

    private void addItemEvidences(Document document, List<ChecklistExecutionItem> items) {
        Font bodyFont = new Font(Font.HELVETICA, 10, Font.NORMAL);
        for (ChecklistExecutionItem item : items) {
            try {
                document.add(new Paragraph("Item: " + safe(item.getChecklistItem().getDescricao()), bodyFont));
                List<Evidence> evidences = evidenceRepository.findByChecklistExecutionItemId(item.getId());
                if (evidences.isEmpty()) {
                    document.add(new Paragraph("Sem evidências", bodyFont));
                    document.add(new Paragraph(" "));
                    continue;
                }
                for (Evidence evidence : evidences) {
                    try {
                        if (evidence.getMimeType() != null && evidence.getMimeType().startsWith("image")) {
                            byte[] bytes = storageService.read(evidence.getUrl());
                            Image image = Image.getInstance(bytes);
                            image.scaleToFit(320, 220);
                            document.add(image);
                        } else {
                            document.add(new Paragraph("Evidência: " + safe(evidence.getUrl()), bodyFont));
                        }
                    } catch (Exception ignored) {
                        document.add(new Paragraph("Evidência: " + safe(evidence.getUrl()), bodyFont));
                    }
                    document.add(new Paragraph(" "));
                }
            } catch (Exception ignored) {
            }
        }
    }

    private byte[] decodeBase64Image(String raw) {
        String value = raw;
        if (raw.contains(",")) {
            value = raw.substring(raw.indexOf(',') + 1);
        }
        return Base64.getDecoder().decode(value);
    }
}
