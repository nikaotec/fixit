package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.ExecutionPhoto;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ExecutionPhotoRepository extends JpaRepository<ExecutionPhoto, Long> {
    List<ExecutionPhoto> findByExecutionId(Long executionId);
}
