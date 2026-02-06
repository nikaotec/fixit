package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {
}
