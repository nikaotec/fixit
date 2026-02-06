package com.nikao.ordemservico.dto;

import com.nikao.ordemservico.domain.TipoCliente;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ClienteRequest {

    @NotNull(message = "Tipo de cliente é obrigatório")
    private TipoCliente tipo;

    @NotBlank(message = "Nome é obrigatório")
    private String nome;

    @NotBlank(message = "Documento é obrigatório")
    private String documento;

    @Email(message = "Email inválido")
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
    private String notasInternas;
}
