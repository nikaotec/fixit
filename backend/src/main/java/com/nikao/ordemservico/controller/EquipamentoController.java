package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.Equipamento;
import com.nikao.ordemservico.repository.EquipamentoRepository;
import com.nikao.ordemservico.service.CurrentUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.nikao.ordemservico.dto.ClienteResponse;
import com.nikao.ordemservico.dto.EquipamentoResponse;
import org.springframework.beans.BeanUtils;
import java.util.stream.Collectors;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/equipamentos")
public class EquipamentoController {

    @Autowired
    EquipamentoRepository equipamentoRepository;

    @Autowired
    CurrentUserService currentUserService;

    @GetMapping
    public List<EquipamentoResponse> getAllEquipamentos() {
        var user = currentUserService.getCurrentUser();
        return equipamentoRepository.findByCompanyId(user.getCompany().getId()).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public EquipamentoResponse getById(@PathVariable Long id) {
        var user = currentUserService.getCurrentUser();
        Equipamento equipamento = equipamentoRepository.findById(id).orElseThrow();
        if (!equipamento.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Equipamento nao pertence a empresa do usuario");
        }
        return toResponse(equipamento);
    }

    @PostMapping
    public Equipamento createEquipamento(@RequestBody Equipamento equipamento) {
        var user = currentUserService.getCurrentUser();
        if (equipamento.getCodigo() != null && !equipamento.getCodigo().isBlank()) {
            String codigo = equipamento.getCodigo().trim();
            if (equipamentoRepository.existsByCodigoAndCompanyId(codigo, user.getCompany().getId())) {
                throw new IllegalStateException("Codigo de equipamento ja cadastrado");
            }
            equipamento.setCodigo(codigo);
        }
        equipamento.setCompany(user.getCompany());
        // Since input is Entity, we can save it directly.
        // Deserialization of incoming JSON won't loop because the incoming JSON
        // usually has just { id: ... } for the client, not a whole nested object
        // that points back to the equipment.
        return equipamentoRepository.save(equipamento);
    }

    @PutMapping("/{id}")
    public Equipamento updateEquipamento(@PathVariable Long id, @RequestBody Equipamento payload) {
        var user = currentUserService.getCurrentUser();
        Equipamento equipamento = equipamentoRepository.findById(id).orElseThrow();
        if (!equipamento.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Equipamento nao pertence a empresa do usuario");
        }
        if (payload.getCodigo() != null && !payload.getCodigo().isBlank()) {
            String codigo = payload.getCodigo().trim();
            if (equipamentoRepository.existsByCodigoAndCompanyIdAndIdNot(
                    codigo, user.getCompany().getId(), equipamento.getId())) {
                throw new IllegalStateException("Codigo de equipamento ja cadastrado");
            }
            payload.setCodigo(codigo);
        }

        equipamento.setNome(payload.getNome());
        equipamento.setCodigo(payload.getCodigo());
        equipamento.setDescricao(payload.getDescricao());
        equipamento.setLocalizacao(payload.getLocalizacao());
        equipamento.setQrCode(payload.getQrCode());
        equipamento.setFabricante(payload.getFabricante());
        equipamento.setModelo(payload.getModelo());
        equipamento.setNumeroSerie(payload.getNumeroSerie());
        equipamento.setClasseRisco(payload.getClasseRisco());
        equipamento.setGeofenceRadiusM(payload.getGeofenceRadiusM());
        equipamento.setLatitude(payload.getLatitude());
        equipamento.setLongitude(payload.getLongitude());
        equipamento.setCliente(payload.getCliente());

        return equipamentoRepository.save(equipamento);
    }

    @DeleteMapping("/{id}")
    public void deleteEquipamento(@PathVariable Long id) {
        var user = currentUserService.getCurrentUser();
        Equipamento equipamento = equipamentoRepository.findById(id).orElseThrow();
        if (!equipamento.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Equipamento nao pertence a empresa do usuario");
        }
        equipamentoRepository.delete(equipamento);
    }

    @GetMapping("/cliente/{clienteId}")
    public List<EquipamentoResponse> getByCliente(@PathVariable UUID clienteId) {
        var user = currentUserService.getCurrentUser();
        return equipamentoRepository.findByClienteIdAndCompanyId(clienteId, user.getCompany().getId()).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    private EquipamentoResponse toResponse(Equipamento equipamento) {
        EquipamentoResponse res = new EquipamentoResponse();
        res.setId(equipamento.getId());
        res.setNome(equipamento.getNome());
        res.setCodigo(equipamento.getCodigo());
        res.setDescricao(equipamento.getDescricao());
        res.setLocalizacao(equipamento.getLocalizacao());
        res.setQrCode(equipamento.getQrCode());
        res.setLatitude(equipamento.getLatitude());
        res.setLongitude(equipamento.getLongitude());

        if (equipamento.getCliente() != null) {
            ClienteResponse cli = new ClienteResponse();
            BeanUtils.copyProperties(equipamento.getCliente(), cli);
            res.setCliente(cli);
        }
        return res;
    }
}
