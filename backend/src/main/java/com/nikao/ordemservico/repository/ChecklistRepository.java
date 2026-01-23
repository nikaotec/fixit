package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.Checklist;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChecklistRepository extends JpaRepository<Checklist, Long> {
}
