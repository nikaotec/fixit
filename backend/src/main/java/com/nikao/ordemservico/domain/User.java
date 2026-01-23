package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String password;

    private String fcmToken;
    private boolean active = true;

    @Enumerated(EnumType.STRING)
    private Role role; // ADMIN, GESTOR, TECNICO, CLIENTE

    private LocalDateTime createdAt = LocalDateTime.now();

    // Locale preference (pt, en, etc)
    private String locale = "pt";
}
