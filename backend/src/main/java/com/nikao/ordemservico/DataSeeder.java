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
            PasswordEncoder passwordEncoder) {
        return args -> {
            // Users
            if (userRepository.count() == 0) {
                User admin = new User();
                admin.setName("Admin User");
                admin.setEmail("admin@fixit.com");
                admin.setPassword(passwordEncoder.encode("admin123"));
                admin.setRole(Role.ADMIN);
                admin.setLocale("pt");

                User tech = new User();
                tech.setName("Tecnico Joao");
                tech.setEmail("tech@fixit.com");
                tech.setPassword(passwordEncoder.encode("tech123"));
                tech.setRole(Role.TECNICO);
                tech.setLocale("en");

                userRepository.saveAll(Arrays.asList(admin, tech));
            }

            // Clientes
            if (clienteRepository.count() == 0) {
                Cliente c1 = new Cliente();
                c1.setNome("Acme Corp");
                c1.setDocumento("12345678000199");
                c1.setEmail("contact@acme.com");
                clienteRepository.save(c1);

                // Equipamentos
                Equipamento e1 = new Equipamento();
                e1.setNome("Gerador Diesel 500kVA");
                e1.setCodigo("GER-001");
                e1.setLocalizacao("Setor A");
                e1.setQrCode("GER-001-QR");
                e1.setCliente(c1);

                Equipamento e2 = new Equipamento();
                e2.setNome("Ar Condicionado Ind. 50kBTU");
                e2.setCodigo("AC-002");
                e2.setLocalizacao("Setor B");
                e2.setQrCode("AC-002-QR");
                e2.setCliente(c1);

                equipamentoRepository.saveAll(Arrays.asList(e1, e2));
            }

            // Checklists
            if (checklistRepository.count() == 0) {
                Checklist cl = new Checklist();
                cl.setNome("Manutenção Preventiva Gerador");
                cl.setDescricao("Checklist mensal");

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
