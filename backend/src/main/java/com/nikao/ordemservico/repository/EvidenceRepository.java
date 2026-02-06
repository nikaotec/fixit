package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.Evidence;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EvidenceRepository extends JpaRepository<Evidence, Long> {
    long countByChecklistExecutionItemId(Long checklistExecutionItemId);

    java.util.List<Evidence> findByChecklistExecutionItemId(Long checklistExecutionItemId);
}
