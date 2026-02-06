package com.nikao.ordemservico.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@AllArgsConstructor
public class NotificationResponse {
    private Long orderId;
    private String title;
    private String subtitle;
    private String type;
    private LocalDateTime createdAt;
}
