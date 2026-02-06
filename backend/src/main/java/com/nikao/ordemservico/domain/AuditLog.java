package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "audit_logs")
@Data
public class AuditLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "company_id")
    private Company company;

    @ManyToOne
    @JoinColumn(name = "actor_id")
    private User actor;

    @Column(nullable = false)
    private String action;

    @Column(nullable = false)
    private String entity;

    @Column(name = "entity_id", nullable = false)
    private String entityId;

    @Column(columnDefinition = "TEXT")
    private String metadata;

    private String ip;

    @Column(name = "user_agent")
    private String userAgent;

    @Column(name = "device_id")
    private String deviceId;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
