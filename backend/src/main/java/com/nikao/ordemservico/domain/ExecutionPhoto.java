package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "execution_photos")
@Data
public class ExecutionPhoto {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "checklist_execution_id")
    private ChecklistExecution execution;

    private String url;
    private String mimeType;
    private Long sizeBytes;
    private String hashSha256;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
