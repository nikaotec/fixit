package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "signatures")
@Data
public class Assinatura {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "checklist_execution_id")
    private ChecklistExecution checklistExecution;

    @ManyToOne
    @JoinColumn(name = "signer_id")
    private User tecnico;

    @Column(name = "signature_data", columnDefinition = "TEXT")
    private String assinaturaBase64;

    private String signatureHash;

    @Column(name = "signed_at")
    private LocalDateTime dataAssinatura = LocalDateTime.now();
}
