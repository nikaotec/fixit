package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.FavoriteTechnician;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface FavoriteTechnicianRepository extends JpaRepository<FavoriteTechnician, Long> {
    List<FavoriteTechnician> findByUserId(Long userId);

    Optional<FavoriteTechnician> findByUserIdAndTechnicianId(Long userId, Long technicianId);

    boolean existsByUserIdAndTechnicianId(Long userId, Long technicianId);
}
