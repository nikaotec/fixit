package com.nikao.ordemservico.service;

import com.nikao.ordemservico.domain.Cliente;
import com.nikao.ordemservico.domain.TipoCliente;
import com.nikao.ordemservico.dto.ClienteRequest;
import com.nikao.ordemservico.dto.ClienteResponse;
import com.nikao.ordemservico.repository.ClienteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ClienteService {

    private final ClienteRepository clienteRepository;
    private final CurrentUserService currentUserService;

    @Transactional
    public ClienteResponse criarCliente(ClienteRequest request) {
        var user = currentUserService.getCurrentUser();
        // Verificar se documento já existe
        clienteRepository.findByDocumentoAndCompanyId(request.getDocumento(), user.getCompany().getId()).ifPresent(cliente -> {
            throw new com.nikao.ordemservico.exception.DuplicateEntityException(
                    "Cliente com este documento já existe", cliente.getId());
        });

        Cliente cliente = new Cliente();
        cliente.setCompany(user.getCompany());
        mapearRequestParaEntity(request, cliente);

        Cliente clienteSalvo = clienteRepository.save(cliente);
        return mapearEntityParaResponse(clienteSalvo);
    }

    @Transactional
    public ClienteResponse atualizarCliente(UUID id, ClienteRequest request) {
        var user = currentUserService.getCurrentUser();
        Cliente cliente = clienteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cliente não encontrado"));
        if (!cliente.getCompany().getId().equals(user.getCompany().getId())) {
            throw new RuntimeException("Cliente não pertence à sua empresa");
        }

        // Verificar se está tentando alterar para um documento que já existe
        if (!cliente.getDocumento().equals(request.getDocumento())) {
            clienteRepository.findByDocumentoAndCompanyId(request.getDocumento(), user.getCompany().getId()).ifPresent(existing -> {
                throw new com.nikao.ordemservico.exception.DuplicateEntityException(
                        "Já existe um cliente com este documento", existing.getId());
            });
        }

        mapearRequestParaEntity(request, cliente);
        Cliente clienteAtualizado = clienteRepository.save(cliente);
        return mapearEntityParaResponse(clienteAtualizado);
    }

    @Transactional(readOnly = true)
    public ClienteResponse buscarPorId(UUID id) {
        var user = currentUserService.getCurrentUser();
        Cliente cliente = clienteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cliente não encontrado"));
        if (!cliente.getCompany().getId().equals(user.getCompany().getId())) {
            throw new RuntimeException("Cliente não pertence à sua empresa");
        }
        return mapearEntityParaResponse(cliente);
    }

    @Transactional(readOnly = true)
    public List<ClienteResponse> listarTodos() {
        var user = currentUserService.getCurrentUser();
        return clienteRepository.findByCompanyId(user.getCompany().getId()).stream()
                .map(this::mapearEntityParaResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ClienteResponse> listarAtivos() {
        var user = currentUserService.getCurrentUser();
        return clienteRepository.findByAtivoTrueAndCompanyId(user.getCompany().getId()).stream()
                .map(this::mapearEntityParaResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ClienteResponse> buscarPorNome(String nome) {
        var user = currentUserService.getCurrentUser();
        return clienteRepository.findByNomeContainingIgnoreCaseAndCompanyId(nome, user.getCompany().getId()).stream()
                .map(this::mapearEntityParaResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ClienteResponse> listarPorTipo(TipoCliente tipo) {
        var user = currentUserService.getCurrentUser();
        return clienteRepository.findByTipoAndCompanyId(tipo, user.getCompany().getId()).stream()
                .map(this::mapearEntityParaResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public void desativarCliente(UUID id) {
        var user = currentUserService.getCurrentUser();
        Cliente cliente = clienteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cliente não encontrado"));
        if (!cliente.getCompany().getId().equals(user.getCompany().getId())) {
            throw new RuntimeException("Cliente não pertence à sua empresa");
        }
        cliente.setAtivo(false);
        clienteRepository.save(cliente);
    }

    @Transactional
    public void ativarCliente(UUID id) {
        var user = currentUserService.getCurrentUser();
        Cliente cliente = clienteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cliente não encontrado"));
        if (!cliente.getCompany().getId().equals(user.getCompany().getId())) {
            throw new RuntimeException("Cliente não pertence à sua empresa");
        }
        cliente.setAtivo(true);
        clienteRepository.save(cliente);
    }

    @Transactional
    public void deletarCliente(UUID id) {
        var user = currentUserService.getCurrentUser();
        Cliente cliente = clienteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cliente não encontrado"));
        if (!cliente.getCompany().getId().equals(user.getCompany().getId())) {
            throw new RuntimeException("Cliente não pertence à sua empresa");
        }
        if (!clienteRepository.existsById(id)) {
            throw new RuntimeException("Cliente não encontrado");
        }
        clienteRepository.deleteById(id);
    }

    private void mapearRequestParaEntity(ClienteRequest request, Cliente cliente) {
        cliente.setTipo(request.getTipo());
        cliente.setNome(request.getNome());
        cliente.setDocumento(request.getDocumento());
        cliente.setEmail(request.getEmail());
        cliente.setTelefone(request.getTelefone());

        // Endereço
        cliente.setCep(request.getCep());
        cliente.setRua(request.getRua());
        cliente.setNumero(request.getNumero());
        cliente.setBairro(request.getBairro());
        cliente.setCidade(request.getCidade());
        cliente.setEstado(request.getEstado());
        cliente.setComplemento(request.getComplemento());

        // Contato
        cliente.setNomeContato(request.getNomeContato());
        cliente.setCargoContato(request.getCargoContato());

        // Notas
        cliente.setNotasInternas(request.getNotasInternas());
    }

    private ClienteResponse mapearEntityParaResponse(Cliente cliente) {
        ClienteResponse response = new ClienteResponse();
        response.setId(cliente.getId());
        response.setTipo(cliente.getTipo());
        response.setNome(cliente.getNome());
        response.setDocumento(cliente.getDocumento());
        response.setEmail(cliente.getEmail());
        response.setTelefone(cliente.getTelefone());

        // Endereço
        response.setCep(cliente.getCep());
        response.setRua(cliente.getRua());
        response.setNumero(cliente.getNumero());
        response.setBairro(cliente.getBairro());
        response.setCidade(cliente.getCidade());
        response.setEstado(cliente.getEstado());
        response.setComplemento(cliente.getComplemento());

        // Contato
        response.setNomeContato(cliente.getNomeContato());
        response.setCargoContato(cliente.getCargoContato());

        // Notas e metadados
        response.setNotasInternas(cliente.getNotasInternas());
        response.setAtivo(cliente.getAtivo());
        response.setCriadoEm(cliente.getCriadoEm());
        response.setAtualizadoEm(cliente.getAtualizadoEm());

        return response;
    }
}
