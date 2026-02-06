package com.nikao.ordemservico.dto;

import lombok.Data;
import java.util.UUID;

@Data
public class EquipamentoResponse {
    private Long id;
    private String nome;
    private String codigo;
    private String descricao;
    private String localizacao;
    private String qrCode;
    private Double latitude;
    private Double longitude;
    private ClienteResponse cliente;
}
