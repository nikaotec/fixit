package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.Company;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface CompanyRepository extends JpaRepository<Company, UUID> {
}
