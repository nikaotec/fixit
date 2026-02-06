package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "checklist_execution_items")
@Data
public class ChecklistExecutionItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "checklist_execution_id")
    @JsonIgnore
    private ChecklistExecution checklistExecution;

    @ManyToOne
    @JoinColumn(name = "checklist_item_id")
    private ChecklistItem checklistItem;

    @Column(nullable = false)
    private boolean status;

    @Column(columnDefinition = "TEXT")
    private String observation;

    @Column(name = "evidence_required", nullable = false)
    private boolean evidenceRequired;

    @Column(name = "performed_at", nullable = false)
    private LocalDateTime performedAt = LocalDateTime.now();

    @OneToMany(mappedBy = "checklistExecutionItem", cascade = CascadeType.ALL)
    @JsonIgnore
    private List<Evidence> evidences;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
