package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.TipoCliente;
import com.nikao.ordemservico.dto.ClienteRequest;
import com.nikao.ordemservico.dto.ClienteResponse;
import com.nikao.ordemservico.service.ClienteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/clientes")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ClienteController {

    private final ClienteService clienteService;

    @PostMapping
    public ResponseEntity<ClienteResponse> criarCliente(@Valid @RequestBody ClienteRequest request) {
        System.out.println("[ClienteController.criarCliente] Recebendo requisição para criar cliente: " + request);
        ClienteResponse response = clienteService.criarCliente(request);
        System.out.println("[ClienteController.criarCliente] Cliente criado com sucesso: " + response);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ClienteResponse> atualizarCliente(
            @PathVariable UUID id,
            @Valid @RequestBody ClienteRequest request) {
        ClienteResponse response = clienteService.atualizarCliente(id, request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ClienteResponse> buscarPorId(@PathVariable UUID id) {
        ClienteResponse response = clienteService.buscarPorId(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<ClienteResponse>> listarTodos(
            @RequestParam(required = false) Boolean apenasAtivos,
            @RequestParam(required = false) String nome,
            @RequestParam(required = false) TipoCliente tipo) {

        List<ClienteResponse> clientes;

        if (nome != null && !nome.isEmpty()) {
            clientes = clienteService.buscarPorNome(nome);
        } else if (tipo != null) {
            clientes = clienteService.listarPorTipo(tipo);
        } else if (Boolean.TRUE.equals(apenasAtivos)) {
            clientes = clienteService.listarAtivos();
        } else {
            clientes = clienteService.listarTodos();
        }

        return ResponseEntity.ok(clientes);
    }

    @PatchMapping("/{id}/desativar")
    public ResponseEntity<Void> desativarCliente(@PathVariable UUID id) {
        clienteService.desativarCliente(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/ativar")
    public ResponseEntity<Void> ativarCliente(@PathVariable UUID id) {
        clienteService.ativarCliente(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletarCliente(@PathVariable UUID id) {
        clienteService.deletarCliente(id);
        return ResponseEntity.noContent().build();
    }
}
