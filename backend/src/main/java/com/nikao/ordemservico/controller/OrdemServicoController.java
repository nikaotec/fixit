package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.OrdemServico;
import com.nikao.ordemservico.repository.OrdemServicoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/ordens")
public class OrdemServicoController {

    @Autowired
    OrdemServicoRepository ordemServicoRepository;

    @GetMapping
    public List<OrdemServico> getAllOrdens() {
        return ordemServicoRepository.findAll();
    }

    @PostMapping
    public OrdemServico createOrdem(@RequestBody OrdemServico ordem) {
        return ordemServicoRepository.save(ordem);
    }

    @PostMapping("/{id}/finalizar")
    public OrdemServico finalizarOrdem(@PathVariable Long id, @RequestBody OrdemServico ordemAtualizada) {
        OrdemServico ordem = ordemServicoRepository.findById(id).orElseThrow();
        ordem.setStatus(ordemAtualizada.getStatus()); // Should be FINALIZADA
        ordem.setExecucoes(ordemAtualizada.getExecucoes());
        ordem.setAssinatura(ordemAtualizada.getAssinatura());
        ordem.setDataFinalizacao(LocalDateTime.now());

        // Ensure relationships are set for cascade
        if (ordem.getExecucoes() != null) {
            ordem.getExecucoes().forEach(e -> e.setOrdemServico(ordem));
        }
        if (ordem.getAssinatura() != null) {
            ordem.getAssinatura().setOrdemServico(ordem);
        }

        return ordemServicoRepository.save(ordem);
    }
}
