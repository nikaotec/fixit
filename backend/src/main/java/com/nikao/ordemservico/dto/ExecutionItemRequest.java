package com.nikao.ordemservico.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ExecutionItemRequest {
    @NotNull
    private Long checklistItemId;

    @NotNull
    private Boolean status;

    private String observation;
}
