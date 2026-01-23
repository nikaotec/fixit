package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class ChecklistItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String descricao;
    private int ordem;
    private boolean obrigatorioFoto;

    @ManyToOne
    @JoinColumn(name = "checklist_id")
    private Checklist checklist;
}
