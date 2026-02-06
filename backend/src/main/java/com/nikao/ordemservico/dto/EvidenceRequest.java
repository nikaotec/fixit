package com.nikao.ordemservico.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class EvidenceRequest {
    @NotNull
    private Long checklistExecutionItemId;

    @NotBlank
    private String url;

    @NotBlank
    private String hashSha256;

    private String mimeType;
    private Long sizeBytes;
}
