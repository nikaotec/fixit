package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.Checklist;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ChecklistRepository extends JpaRepository<Checklist, Long> {
    List<Checklist> findByCompanyId(java.util.UUID companyId);
}
