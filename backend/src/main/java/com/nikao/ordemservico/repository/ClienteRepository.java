package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.Cliente;
import com.nikao.ordemservico.domain.TipoCliente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClienteRepository extends JpaRepository<Cliente, UUID> {

    Optional<Cliente> findByDocumento(String documento);
    Optional<Cliente> findByDocumentoAndCompanyId(String documento, java.util.UUID companyId);

    List<Cliente> findByCompanyId(java.util.UUID companyId);

    List<Cliente> findByTipoAndCompanyId(TipoCliente tipo, java.util.UUID companyId);

    List<Cliente> findByAtivoTrueAndCompanyId(java.util.UUID companyId);

    List<Cliente> findByNomeContainingIgnoreCaseAndCompanyId(String nome, java.util.UUID companyId);

    boolean existsByDocumentoAndCompanyId(String documento, java.util.UUID companyId);
}
