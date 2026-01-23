package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.Equipamento;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface EquipamentoRepository extends JpaRepository<Equipamento, Long> {
    List<Equipamento> findByClienteId(Long clienteId);

    Optional<Equipamento> findByQrCode(String qrCode);
}
