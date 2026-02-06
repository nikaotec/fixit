package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.time.LocalDateTime;

@Entity
@Table(name = "evidences")
@Data
public class Evidence {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "checklist_execution_item_id")
    @JsonIgnore
    private ChecklistExecutionItem checklistExecutionItem;

    @Column(nullable = false)
    private String url;

    @Column(name = "hash_sha256", nullable = false)
    private String hashSha256;

    @Column(name = "mime_type")
    private String mimeType;

    @Column(name = "size_bytes")
    private Long sizeBytes;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
