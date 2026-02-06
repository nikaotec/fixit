package com.nikao.ordemservico.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ExecutionFinalizeRequest {
    @NotBlank
    private String signatureBase64;

    private String finalObservation;
}
