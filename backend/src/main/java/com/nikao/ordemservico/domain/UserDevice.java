package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_devices")
@Data
public class UserDevice {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "device_id", nullable = false)
    private String deviceId;

    @Column(nullable = false)
    private boolean active = true;

    @Column(name = "registered_at", nullable = false, updatable = false)
    private LocalDateTime registeredAt = LocalDateTime.now();
}
