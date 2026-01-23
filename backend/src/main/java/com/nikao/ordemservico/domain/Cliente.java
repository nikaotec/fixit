package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.util.List;

@Entity
@Data
public class Cliente {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nome;
    private String documento; // CPF/CNPJ
    private String email;
    private String telefone;

    @OneToMany(mappedBy = "cliente")
    private List<Equipamento> equipamentos;
}
