package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
public class OrdemServico {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Equipamento equipamento;

    @ManyToOne
    private Checklist checklist;

    @ManyToOne
    private User criador;

    @ManyToOne
    private User responsavel; // Tecnico

    @Enumerated(EnumType.STRING)
    private StatusOrdem status;

    private String prioridade; // BAIXA, MEDIA, ALTA
    private LocalDateTime dataCriacao = LocalDateTime.now();
    private LocalDateTime dataPrevista;
    private LocalDateTime dataFinalizacao;

    @OneToMany(mappedBy = "ordemServico", cascade = CascadeType.ALL)
    private List<ChecklistExecucao> execucoes;

    @OneToOne(mappedBy = "ordemServico", cascade = CascadeType.ALL)
    private Assinatura assinatura;
}

enum StatusOrdem {
    ABERTA, EM_ANDAMENTO, FINALIZADA, CANCELADA, ATRASADA
}
