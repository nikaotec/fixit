package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.OrdemServico;
import com.nikao.ordemservico.repository.ChecklistExecutionRepository;
import com.nikao.ordemservico.repository.OrdemServicoRepository;
import com.nikao.ordemservico.service.CurrentUserService;
import com.nikao.ordemservico.service.N8nService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/ordens")
public class OrdemServicoController {

    @Autowired
    OrdemServicoRepository ordemServicoRepository;

    @Autowired
    ChecklistExecutionRepository checklistExecutionRepository;

    @Autowired
    CurrentUserService currentUserService;

    @Autowired
    N8nService n8nService;


    @GetMapping
    public List<OrdemServico> getAllOrdens() {
        var user = currentUserService.getCurrentUser();
        return ordemServicoRepository.findByCriadorIdOrResponsavelId(
                user.getId(),
                user.getId()
        );
    }

    @GetMapping("/{id}")
    public OrdemServico getOrdemById(@PathVariable Long id) {
        var user = currentUserService.getCurrentUser();
        OrdemServico ordem = ordemServicoRepository.findById(id).orElseThrow();
        boolean isCreator = ordem.getCriador() != null
                && ordem.getCriador().getId().equals(user.getId());
        boolean isResponsible = ordem.getResponsavel() != null
                && ordem.getResponsavel().getId().equals(user.getId());
        if (!isCreator && !isResponsible) {
            throw new IllegalStateException("Ordem nao pertence ao usuario");
        }
        return ordem;
    }

    @PostMapping
    public OrdemServico createOrdem(@RequestBody OrdemServico ordem) {
        var user = currentUserService.getCurrentUser();
        ordem.setCompany(user.getCompany());
        if (ordem.getTipo() == null) {
            ordem.setTipo(com.nikao.ordemservico.domain.TipoOrdem.MANUTENCAO);
        }
        if (ordem.getTipo() == com.nikao.ordemservico.domain.TipoOrdem.MANUTENCAO) {
            if (ordem.getEquipamento() == null) {
                throw new IllegalStateException("Equipamento obrigatorio para manutencao");
            }
            if (ordem.getChecklist() == null) {
                throw new IllegalStateException("Checklist obrigatorio para manutencao");
            }
        } else {
            if (ordem.getProblemDescription() == null || ordem.getProblemDescription().isBlank()) {
                throw new IllegalStateException("Descricao do problema obrigatoria");
            }
            if (ordem.getEquipmentBrand() == null || ordem.getEquipmentBrand().isBlank()) {
                throw new IllegalStateException("Marca obrigatoria");
            }
            if (ordem.getEquipmentModel() == null || ordem.getEquipmentModel().isBlank()) {
                throw new IllegalStateException("Modelo obrigatorio");
            }
            ordem.setChecklist(null);
        }
        if (ordem.getCriador() == null) {
            ordem.setCriador(user);
        }
        if (ordem.getResponsavel() == null) {
            ordem.setResponsavel(user);
        }
        OrdemServico saved = ordemServicoRepository.save(ordem);
        n8nService.notifyOrderAssigned(saved);
        return saved;
    }

    @PostMapping("/{id}/finalizar")
    public OrdemServico finalizarOrdem(@PathVariable Long id) {
        var user = currentUserService.getCurrentUser();
        OrdemServico ordem = ordemServicoRepository.findById(id).orElseThrow();
        if (!ordem.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Ordem nao pertence a empresa do usuario");
        }
        boolean hasFinalizedExecution = checklistExecutionRepository.findByOrdemServicoId(id).stream()
                .anyMatch(exec -> exec.getFinishedAt() != null && "FINALIZED".equals(exec.getStatus()));
        if (!hasFinalizedExecution) {
            throw new IllegalStateException("Nao existe execucao finalizada para esta ordem");
        }
        ordem.setStatus(com.nikao.ordemservico.domain.StatusOrdem.FINALIZADA);
        ordem.setDataFinalizacao(LocalDateTime.now());

        return ordemServicoRepository.save(ordem);
    }
}
