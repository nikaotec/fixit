package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.TechnicianReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TechnicianReviewRepository extends JpaRepository<TechnicianReview, Long> {

    @Query("select avg(r.rating) from TechnicianReview r where r.technician.id = :technicianId")
    Double averageRating(@Param("technicianId") Long technicianId);

    long countByTechnicianId(Long technicianId);
}
