package com.nikao.ordemservico.dto;

import lombok.Data;

@Data
public class ExecutionLookupRequest {
    private String equipmentCode;
    private String qrCodePayload;
}
