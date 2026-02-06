package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.Checklist;
import com.nikao.ordemservico.domain.ChecklistItem;
import com.nikao.ordemservico.repository.ChecklistRepository;
import com.nikao.ordemservico.service.CurrentUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/checklists")
public class ChecklistController {

    @Autowired
    ChecklistRepository checklistRepository;

    @Autowired
    CurrentUserService currentUserService;

    @GetMapping
    public List<Checklist> getAllChecklists() {
        var user = currentUserService.getCurrentUser();
        return checklistRepository.findByCompanyId(user.getCompany().getId());
    }

    @GetMapping("/{id}")
    public Checklist getChecklistById(@PathVariable Long id) {
        var user = currentUserService.getCurrentUser();
        Checklist checklist = checklistRepository.findById(id).orElseThrow();
        if (!checklist.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Checklist nao pertence a empresa do usuario");
        }
        return checklist;
    }

    @PostMapping
    public Checklist createChecklist(@RequestBody Checklist checklist) {
        var user = currentUserService.getCurrentUser();
        checklist.setCompany(user.getCompany());
        normalizeItems(checklist);
        return checklistRepository.save(checklist);
    }

    @PutMapping("/{id}")
    public Checklist updateChecklist(@PathVariable Long id, @RequestBody Checklist payload) {
        var user = currentUserService.getCurrentUser();
        Checklist checklist = checklistRepository.findById(id).orElseThrow();
        if (!checklist.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Checklist nao pertence a empresa do usuario");
        }

        checklist.setNome(payload.getNome());
        checklist.setDescricao(payload.getDescricao());
        checklist.setAtivo(payload.isAtivo());
        checklist.setVersao(checklist.getVersao() + 1);

        if (payload.getItens() != null) {
            if (checklist.getItens() == null) {
                checklist.setItens(new ArrayList<>());
            } else {
                checklist.getItens().clear();
            }
            checklist.getItens().addAll(payload.getItens());
            normalizeItems(checklist);
        }

        return checklistRepository.save(checklist);
    }

    private void normalizeItems(Checklist checklist) {
        if (checklist.getItens() == null) return;
        int ordem = 1;
        for (ChecklistItem item : checklist.getItens()) {
            item.setChecklist(checklist);
            if (item.getOrdem() == 0) {
                item.setOrdem(ordem);
            }
            ordem++;
        }
    }
}
