package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.OrdemServico;
import com.nikao.ordemservico.domain.StatusOrdem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface OrdemServicoRepository extends JpaRepository<OrdemServico, Long> {
    List<OrdemServico> findByResponsavelId(Long responsavelId);

    List<OrdemServico> findByStatus(StatusOrdem status);

    List<OrdemServico> findByCompanyId(java.util.UUID companyId);

    List<OrdemServico> findByCriadorIdOrResponsavelId(Long criadorId, Long responsavelId);

    boolean existsByResponsavelIdAndStatus(Long responsavelId, StatusOrdem status);

    long countByResponsavelIdAndStatus(Long responsavelId, StatusOrdem status);

    Optional<OrdemServico> findFirstByEquipamentoIdAndStatusInOrderByDataPrevistaAsc(
            Long equipamentoId,
            List<StatusOrdem> status
    );
}
