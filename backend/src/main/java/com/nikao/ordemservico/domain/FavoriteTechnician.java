package com.nikao.ordemservico.domain;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "favorite_technicians",
        uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "technician_id"})
)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FavoriteTechnician {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "technician_id", nullable = false)
    private User technician;

    private LocalDateTime createdAt = LocalDateTime.now();
}
