package com.nikao.ordemservico.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ExecutionStartRequest {
    @NotNull
    private Long maintenanceOrderId;

    private String qrCodePayload;

    @NotNull
    private String deviceId;

    @NotNull
    private Double latitude;

    @NotNull
    private Double longitude;

    private Double accuracy;
}
