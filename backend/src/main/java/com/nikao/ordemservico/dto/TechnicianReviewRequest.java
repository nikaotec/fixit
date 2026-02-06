package com.nikao.ordemservico.dto;

import lombok.Data;

@Data
public class TechnicianReviewRequest {
    private double rating;
    private String comment;
}
