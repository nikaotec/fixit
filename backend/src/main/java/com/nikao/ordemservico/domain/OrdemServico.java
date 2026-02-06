package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "maintenance_orders")
@Data
public class OrdemServico {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "equipment_id")
    private Equipamento equipamento;

    @ManyToOne
    @JoinColumn(name = "company_id")
    private Company company;

    @ManyToOne
    @JoinColumn(name = "client_id")
    private Cliente cliente;

    @ManyToOne
    @JoinColumn(name = "checklist_id")
    private Checklist checklist;

    @Enumerated(EnumType.STRING)
    @Column(name = "order_type")
    private TipoOrdem tipo = TipoOrdem.MANUTENCAO;

    @Column(name = "problem_description", columnDefinition = "TEXT")
    private String problemDescription;

    @Column(name = "equipment_brand")
    private String equipmentBrand;

    @Column(name = "equipment_model")
    private String equipmentModel;

    @ManyToOne
    @JoinColumn(name = "creator_id")
    private User criador;

    @ManyToOne
    @JoinColumn(name = "technician_id")
    private User responsavel; // Tecnico

    @Enumerated(EnumType.STRING)
    private StatusOrdem status = StatusOrdem.ABERTA;

    private String prioridade; // BAIXA, MEDIA, ALTA
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime dataCriacao = LocalDateTime.now();

    @Column(name = "scheduled_for")
    private LocalDateTime dataPrevista;

    @Column(name = "finished_at")
    private LocalDateTime dataFinalizacao;

    @OneToMany(mappedBy = "ordemServico", cascade = CascadeType.ALL)
    @JsonIgnore
    private List<ChecklistExecution> execucoes;
}
