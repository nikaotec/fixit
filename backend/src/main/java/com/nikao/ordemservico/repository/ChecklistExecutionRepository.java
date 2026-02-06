package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.ChecklistExecution;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.time.LocalDateTime;

public interface ChecklistExecutionRepository extends JpaRepository<ChecklistExecution, Long> {
    List<ChecklistExecution> findByOrdemServicoId(Long ordemServicoId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select e from ChecklistExecution e where e.id = :id")
    Optional<ChecklistExecution> findByIdForUpdate(@Param("id") Long id);

    @Modifying
    @Query("""
            update ChecklistExecution e
            set e.status = 'FINALIZED',
                e.finishedAt = :finishedAt,
                e.finalObservation = :finalObservation,
                e.integrityHash = :integrityHash,
                e.reportUrl = :reportUrl,
                e.reportHash = :reportHash
            where e.id = :id and (e.status is null or e.status <> 'FINALIZED')
            """)
    int finalizeExecutionIfNotFinalized(
            @Param("id") Long id,
            @Param("finishedAt") LocalDateTime finishedAt,
            @Param("finalObservation") String finalObservation,
            @Param("integrityHash") String integrityHash,
            @Param("reportUrl") String reportUrl,
            @Param("reportHash") String reportHash
    );
}
