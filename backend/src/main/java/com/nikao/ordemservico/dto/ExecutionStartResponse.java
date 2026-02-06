package com.nikao.ordemservico.dto;

import com.nikao.ordemservico.domain.ChecklistItem;
import lombok.Data;
import java.util.List;

@Data
public class ExecutionStartResponse {
    private Long executionId;
    private Long maintenanceOrderId;
    private Long equipmentId;
    private List<ChecklistItem> checklistItems;
    private String orderType;
    private String problemDescription;
}
