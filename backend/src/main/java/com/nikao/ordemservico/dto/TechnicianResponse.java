package com.nikao.ordemservico.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class TechnicianResponse {
    private Long id;
    private String name;
    private String email;
    private String role;
    private String status;
    private double rating;
    private long completed;
    private long reviewCount;
    private String avatarUrl;
}
