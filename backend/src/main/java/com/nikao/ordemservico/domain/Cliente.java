package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "clientes")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoCliente tipo; // INDIVIDUAL ou CORPORATE

    @ManyToOne
    @JoinColumn(name = "company_id")
    private Company company;

    @Column(nullable = false)
    private String nome;

    @Column(unique = true)
    private String documento; // CPF ou CNPJ

    private String email;
    private String telefone;

    // Endereço
    private String cep;
    private String rua;
    private String numero;
    private String bairro;
    private String cidade;
    private String estado;
    private String complemento;

    // Contato principal (opcional)
    private String nomeContato;
    private String cargoContato;

    // Notas internas
    @Column(columnDefinition = "TEXT")
    private String notasInternas;

    @Column(nullable = false)
    private Boolean ativo = true;

    @Column(name = "criado_em", nullable = false, updatable = false)
    private LocalDateTime criadoEm;

    @Column(name = "atualizado_em")
    private LocalDateTime atualizadoEm;

    @OneToMany(mappedBy = "cliente")
    @com.fasterxml.jackson.annotation.JsonIgnore
    private List<Equipamento> equipamentos;

    @OneToMany(mappedBy = "cliente")
    @com.fasterxml.jackson.annotation.JsonIgnore
    private List<OrdemServico> ordensServico;

    @PrePersist
    protected void onCreate() {
        criadoEm = LocalDateTime.now();
        atualizadoEm = LocalDateTime.now();
        if (ativo == null) {
            ativo = true;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        atualizadoEm = LocalDateTime.now();
    }
}
