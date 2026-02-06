package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.ChecklistExecution;
import com.nikao.ordemservico.repository.ChecklistExecutionRepository;
import com.nikao.ordemservico.service.CurrentUserService;
import com.nikao.ordemservico.service.StorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/executions")
public class ExecutionReportController {

    @Autowired
    private ChecklistExecutionRepository checklistExecutionRepository;

    @Autowired
    private StorageService storageService;

    @Autowired
    private CurrentUserService currentUserService;

    @GetMapping("/{id}/report")
    public ResponseEntity<byte[]> getReport(@PathVariable Long id) {
        var user = currentUserService.getCurrentUser();
        ChecklistExecution execution = checklistExecutionRepository.findById(id).orElseThrow();
        if (!execution.getCompany().getId().equals(user.getCompany().getId())) {
            throw new IllegalStateException("Relatorio fora da empresa do usuario");
        }
        if (execution.getReportUrl() == null) {
            throw new IllegalStateException("Relatorio ainda nao gerado");
        }

        byte[] bytes = storageService.read(execution.getReportUrl());
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=execution-" + id + ".pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(bytes);
    }
}
