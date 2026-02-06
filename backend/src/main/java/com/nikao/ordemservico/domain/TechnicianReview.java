package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "technician_reviews")
@Data
public class TechnicianReview {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "company_id")
    private Company company;

    @ManyToOne
    @JoinColumn(name = "technician_id")
    private User technician;

    @ManyToOne
    @JoinColumn(name = "reviewer_id")
    private User reviewer;

    @Column(nullable = false)
    private double rating;

    @Column(length = 500)
    private String comment;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
