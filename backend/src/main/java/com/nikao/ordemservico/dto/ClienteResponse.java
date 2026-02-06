package com.nikao.ordemservico.dto;

import com.nikao.ordemservico.domain.TipoCliente;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class ClienteResponse {

    private UUID id;
    private TipoCliente tipo;
    private String nome;
    private String documento;
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

    // Contato principal
    private String nomeContato;
    private String cargoContato;

    // Notas internas
    private String notasInternas;

    private Boolean ativo;
    private LocalDateTime criadoEm;
    private LocalDateTime atualizadoEm;
}
