package com.nikao.ordemservico;

import com.nikao.ordemservico.domain.*;
import com.nikao.ordemservico.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import java.util.Arrays;
import java.util.List;

@Configuration
@Profile("dev")
public class DataSeeder {

    @Bean
    CommandLineRunner initDatabase(UserRepository userRepository,
            ClienteRepository clienteRepository,
            EquipamentoRepository equipamentoRepository,
            ChecklistRepository checklistRepository,
            CompanyRepository companyRepository,
            TechnicianReviewRepository technicianReviewRepository,
            PasswordEncoder passwordEncoder) {
        return args -> {
            Company company;
            if (companyRepository.count() == 0) {
                Company created = new Company();
                created.setName("Fixit Demo");
                created.setCnpj("12345678000199");
                company = companyRepository.save(created);
            } else {
                company = companyRepository.findAll().get(0);
            }

            // Users
            if (userRepository.count() == 0) {
                User admin = new User();
                admin.setName("Admin User");
                admin.setEmail("admin@fixit.com");
                admin.setPassword(passwordEncoder.encode("admin123"));
                admin.setRole(Role.ADMIN);
                admin.setLocale("pt");
                admin.setCompany(company);

                User tech = new User();
                tech.setName("Tecnico Joao");
                tech.setEmail("tech@fixit.com");
                tech.setPassword(passwordEncoder.encode("tech123"));
                tech.setRole(Role.TECNICO);
                tech.setLocale("en");
                tech.setCompany(company);

                User tech2 = new User();
                tech2.setName("Mariana Costa");
                tech2.setEmail("mariana@fixit.com");
                tech2.setPassword(passwordEncoder.encode("tech123"));
                tech2.setRole(Role.TECNICO);
                tech2.setLocale("pt");
                tech2.setCompany(company);

                User tech3 = new User();
                tech3.setName("Carlos Lima");
                tech3.setEmail("carlos@fixit.com");
                tech3.setPassword(passwordEncoder.encode("tech123"));
                tech3.setRole(Role.TECNICO);
                tech3.setLocale("pt");
                tech3.setCompany(company);

                userRepository.saveAll(Arrays.asList(admin, tech, tech2, tech3));
            }

            if (technicianReviewRepository.count() == 0) {
                List<User> users = userRepository.findAll();
                User admin = users.stream().filter(u -> u.getEmail().equals("admin@fixit.com")).findFirst().orElse(null);
                User tech2 = users.stream().filter(u -> u.getEmail().equals("mariana@fixit.com")).findFirst().orElse(null);
                User tech3 = users.stream().filter(u -> u.getEmail().equals("carlos@fixit.com")).findFirst().orElse(null);
                if (admin != null && tech2 != null) {
                    TechnicianReview r1 = new TechnicianReview();
                    r1.setCompany(company);
                    r1.setReviewer(admin);
                    r1.setTechnician(tech2);
                    r1.setRating(4.8);
                    r1.setComment("Muito cuidadosa e pontual");

                    TechnicianReview r2 = new TechnicianReview();
                    r2.setCompany(company);
                    r2.setReviewer(admin);
                    r2.setTechnician(tech2);
                    r2.setRating(4.6);
                    r2.setComment("Excelente comunicação");

                    technicianReviewRepository.saveAll(Arrays.asList(r1, r2));
                }
                if (admin != null && tech3 != null) {
                    TechnicianReview r3 = new TechnicianReview();
                    r3.setCompany(company);
                    r3.setReviewer(admin);
                    r3.setTechnician(tech3);
                    r3.setRating(4.4);
                    r3.setComment("Bom atendimento");

                    technicianReviewRepository.save(r3);
                }
            }

            // Clientes
            if (clienteRepository.count() == 0) {
                Cliente c1 = new Cliente();
                c1.setNome("Acme Corp");
                c1.setDocumento("12345678000199");
                c1.setEmail("contact@acme.com");
                c1.setCompany(company);
                clienteRepository.save(c1);

                // Equipamentos
                Equipamento e1 = new Equipamento();
                e1.setNome("Gerador Diesel 500kVA");
                e1.setCodigo("GER-001");
                e1.setLocalizacao("Setor A");
                e1.setQrCode("GER-001-QR");
                e1.setCliente(c1);
                e1.setCompany(company);

                Equipamento e2 = new Equipamento();
                e2.setNome("Ar Condicionado Ind. 50kBTU");
                e2.setCodigo("AC-002");
                e2.setLocalizacao("Setor B");
                e2.setQrCode("AC-002-QR");
                e2.setCliente(c1);
                e2.setCompany(company);

                equipamentoRepository.saveAll(Arrays.asList(e1, e2));
            }

            // Checklists
            if (checklistRepository.count() == 0) {
                Checklist cl = new Checklist();
                cl.setNome("Manutenção Preventiva Gerador");
                cl.setDescricao("Checklist mensal");
                cl.setCompany(company);

                ChecklistItem i1 = new ChecklistItem();
                i1.setDescricao("Verificar nível de óleo");
                i1.setOrdem(1);
                i1.setObrigatorioFoto(true);
                i1.setChecklist(cl);

                ChecklistItem i2 = new ChecklistItem();
                i2.setDescricao("Limpeza dos filtros");
                i2.setOrdem(2);
                i2.setChecklist(cl);

                cl.setItens(Arrays.asList(i1, i2));
                checklistRepository.save(cl);
            }
        };
    }
}
