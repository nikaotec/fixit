package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "checklist_executions")
@Data
public class ChecklistExecution {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "company_id")
    private Company company;

    @ManyToOne
    @JoinColumn(name = "maintenance_order_id")
    private OrdemServico ordemServico;

    @ManyToOne
    @JoinColumn(name = "equipment_id")
    private Equipamento equipamento;

    @ManyToOne
    @JoinColumn(name = "technician_id")
    private User tecnico;

    @Column(name = "device_id", nullable = false)
    private String deviceId;

    @Column(name = "started_at", nullable = false)
    private LocalDateTime startedAt = LocalDateTime.now();

    @Column(name = "finished_at")
    private LocalDateTime finishedAt;

    @Column(nullable = false)
    private String status;

    @Column(name = "geo_lat")
    private Double geoLat;

    @Column(name = "geo_lng")
    private Double geoLng;

    @Column(name = "geo_accuracy")
    private Double geoAccuracy;

    @Column(name = "geofence_ok", nullable = false)
    private boolean geofenceOk;

    @Column(name = "integrity_hash")
    private String integrityHash;

    @Column(name = "report_url")
    private String reportUrl;

    @Column(name = "report_hash")
    private String reportHash;

    @Column(name = "final_observation")
    private String finalObservation;

    @OneToMany(mappedBy = "checklistExecution", cascade = CascadeType.ALL)
    private List<ChecklistExecutionItem> itens;

    @OneToOne(mappedBy = "checklistExecution", cascade = CascadeType.ALL)
    private Assinatura assinatura;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
