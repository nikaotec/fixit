package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.OrdemServico;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface OrdemServicoRepository extends JpaRepository<OrdemServico, Long> {
    List<OrdemServico> findByResponsavelId(Long responsavelId);

    List<OrdemServico> findByStatus(String status);
}
