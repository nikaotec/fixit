package com.nikao.ordemservico.service;

import com.nikao.ordemservico.domain.ChecklistExecution;
import com.nikao.ordemservico.domain.OrdemServico;
import com.nikao.ordemservico.domain.User;
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
}
