package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.Checklist;
import com.nikao.ordemservico.repository.ChecklistRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/checklists")
public class ChecklistController {

    @Autowired
    ChecklistRepository checklistRepository;

    @GetMapping
    public List<Checklist> getAllChecklists() {
        return checklistRepository.findAll();
    }

    @PostMapping
    public Checklist createChecklist(@RequestBody Checklist checklist) {
        return checklistRepository.save(checklist);
    }
}
