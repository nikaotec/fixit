package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClienteRepository extends JpaRepository<Cliente, Long> {
}
