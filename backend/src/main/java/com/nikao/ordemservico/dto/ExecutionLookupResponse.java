package com.nikao.ordemservico.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ExecutionLookupResponse {
    private Long maintenanceOrderId;
    private String maintenanceOrderStatus;
    private Long equipmentId;
    private String equipmentName;
    private String equipmentCode;
    private String clientName;
    private String scheduledFor;
    private String qrCodePayload;
}
