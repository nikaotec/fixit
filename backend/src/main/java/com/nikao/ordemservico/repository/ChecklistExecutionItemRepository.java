package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.ChecklistExecutionItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ChecklistExecutionItemRepository extends JpaRepository<ChecklistExecutionItem, Long> {
    List<ChecklistExecutionItem> findByChecklistExecutionId(Long executionId);

    java.util.Optional<ChecklistExecutionItem> findByChecklistExecutionIdAndChecklistItemId(Long executionId, Long checklistItemId);
}
