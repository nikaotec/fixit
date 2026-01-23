package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.Equipamento;
import com.nikao.ordemservico.repository.EquipamentoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/equipamentos")
public class EquipamentoController {

    @Autowired
    EquipamentoRepository equipamentoRepository;

    @GetMapping
    public List<Equipamento> getAllEquipamentos() {
        return equipamentoRepository.findAll();
    }

    @PostMapping
    public Equipamento createEquipamento(@RequestBody Equipamento equipamento) {
        return equipamentoRepository.save(equipamento);
    }

    @GetMapping("/cliente/{clienteId}")
    public List<Equipamento> getByCliente(@PathVariable Long clienteId) {
        return equipamentoRepository.findByClienteId(clienteId);
    }
}
