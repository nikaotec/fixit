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

    @ManyToOne
    @JoinColumn(name = "cliente_id")
    private Cliente cliente;
}
