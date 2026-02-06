package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.Equipamento;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface EquipamentoRepository extends JpaRepository<Equipamento, Long> {
    List<Equipamento> findByClienteId(UUID clienteId);
    List<Equipamento> findByCompanyId(UUID companyId);
    List<Equipamento> findByClienteIdAndCompanyId(UUID clienteId, UUID companyId);

    Optional<Equipamento> findByQrCode(String qrCode);

    Optional<Equipamento> findByQrCodeAndCompanyId(String qrCode, UUID companyId);

    Optional<Equipamento> findByCodigoAndCompanyId(String codigo, UUID companyId);

    boolean existsByCodigoAndCompanyId(String codigo, UUID companyId);

    boolean existsByCodigoAndCompanyIdAndIdNot(String codigo, UUID companyId, Long id);
}
