package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.OrdemServico;
import com.nikao.ordemservico.dto.NotificationResponse;
import com.nikao.ordemservico.dto.PushTestRequest;
import com.nikao.ordemservico.repository.OrdemServicoRepository;
import com.nikao.ordemservico.repository.UserRepository;
import com.nikao.ordemservico.service.CurrentUserService;
import com.nikao.ordemservico.service.N8nService;
import com.nikao.ordemservico.domain.Role;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.Map;

@RestController
@RequestMapping("/notifications")
public class NotificationController {

    @Autowired
    private OrdemServicoRepository ordemServicoRepository;

    @Autowired
    private CurrentUserService currentUserService;

    @Autowired
    private N8nService n8nService;

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public List<NotificationResponse> getNotifications() {
        var user = currentUserService.getCurrentUser();
        var orders = ordemServicoRepository.findByCompanyId(user.getCompany().getId());

        return orders.stream()
                .sorted(Comparator.comparing(OrdemServico::getDataCriacao).reversed())
                .limit(20)
                .map(this::toNotification)
                .collect(Collectors.toList());
    }

    @PostMapping("/test-push")
    public Map<String, Object> testPush(@RequestBody(required = false) PushTestRequest request) {
        var user = currentUserService.getCurrentUser();
        String title = request != null ? request.getTitle() : null;
        String message = request != null ? request.getMessage() : null;
        n8nService.notifyTestPush(user, title, message);
        return Map.of("status", "queued");
    }

    @PostMapping("/test-push/{userId}")
    public Map<String, Object> testPushForUser(
            @PathVariable Long userId,
            @RequestBody(required = false) PushTestRequest request
    ) {
        var current = currentUserService.getCurrentUser();
        if (current.getRole() != Role.ADMIN
                && current.getRole() != Role.GESTOR
                && current.getRole() != Role.MANAGER) {
            throw new IllegalStateException("Acesso negado");
        }
        var user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException("User not found"));
        String title = request != null ? request.getTitle() : null;
        String message = request != null ? request.getMessage() : null;
        n8nService.notifyTestPush(user, title, message);
        return Map.of("status", "queued", "userId", userId);
    }

    private NotificationResponse toNotification(OrdemServico ordem) {
        String type;
        String title;
        String subtitle;
        switch (ordem.getStatus()) {
            case ATRASADA:
                type = "OVERDUE";
                title = "Overdue maintenance";
                subtitle = "Order #" + ordem.getId() + " is overdue.";
                break;
            case FINALIZADA:
                type = "COMPLETED";
                title = "Order completed";
                subtitle = "Order #" + ordem.getId() + " completed.";
                break;
            case EM_ANDAMENTO:
                type = "IN_PROGRESS";
                title = "Order in progress";
                subtitle = "Order #" + ordem.getId() + " is in progress.";
                break;
            default:
                type = "PENDING";
                title = "Order pending";
                subtitle = "Order #" + ordem.getId() + " pending.";
        }

        var createdAt = ordem.getDataFinalizacao() != null
                ? ordem.getDataFinalizacao()
                : ordem.getDataCriacao();

        return new NotificationResponse(
                ordem.getId(),
                title,
                subtitle,
                type,
                createdAt
        );
    }
}
