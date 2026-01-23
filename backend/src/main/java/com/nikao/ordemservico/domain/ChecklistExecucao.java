package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class ChecklistExecucao {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "ordem_servico_id")
    private OrdemServico ordemServico;

    @ManyToOne
    private ChecklistItem checklistItem;

    private boolean status; // Conforme / Não Conforme
    private String observacao;
    private String fotoUrl;
}
