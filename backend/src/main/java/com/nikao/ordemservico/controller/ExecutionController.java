package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.ChecklistExecution;
import com.nikao.ordemservico.domain.ChecklistExecutionItem;
import com.nikao.ordemservico.domain.Evidence;
import com.nikao.ordemservico.domain.ExecutionPhoto;
import com.nikao.ordemservico.dto.*;
import com.nikao.ordemservico.service.ExecutionService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/executions")
public class ExecutionController {

    @Autowired
    private ExecutionService executionService;

    @PostMapping("/start")
    public ExecutionStartResponse start(@Valid @RequestBody ExecutionStartRequest request) {
        return executionService.startExecution(request);
    }

    @PostMapping("/lookup")
    public ExecutionLookupResponse lookup(@RequestBody ExecutionLookupRequest request) {
        return executionService.lookupExecution(request);
    }

    @PostMapping("/{id}/items")
    public ChecklistExecutionItem recordItem(@PathVariable Long id, @Valid @RequestBody ExecutionItemRequest request) {
        return executionService.recordItem(id, request);
    }

    @PostMapping("/evidences")
    public Evidence addEvidence(@Valid @RequestBody EvidenceRequest request) {
        return executionService.addEvidence(request);
    }

    @PostMapping("/evidences/upload")
    public Evidence uploadEvidence(
            @RequestParam("checklistExecutionItemId") Long checklistExecutionItemId,
            @RequestParam("file") MultipartFile file
    ) {
        return executionService.uploadEvidence(checklistExecutionItemId, file);
    }

    @PostMapping("/{id}/photos/upload")
    public ExecutionPhoto uploadExecutionPhoto(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file
    ) {
        return executionService.uploadExecutionPhoto(id, file);
    }

    @PostMapping("/{id}/finalize")
    public ResponseEntity<Void> finalizeExecution(@PathVariable Long id, @Valid @RequestBody ExecutionFinalizeRequest request) {
        executionService.finalizeExecution(id, request);
        return ResponseEntity.ok().build();
    }
}
