package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Equipamento {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nome;
    private String codigo;
    private String descricao;
    private String localizacao;
    private String qrCode;

    private String fabricante;
    private String modelo;
    private String numeroSerie;
    private String classeRisco;
    private Integer geofenceRadiusM = 100;

    private Double latitude;
    private Double longitude;

    @ManyToOne
    @JoinColumn(name = "company_id")
    private Company company;

    @ManyToOne
    @JoinColumn(name = "cliente_id")
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "equipamentos", "ordensServico" })
    private Cliente cliente;
}
