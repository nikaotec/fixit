package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.OrdemServico;
import com.nikao.ordemservico.dto.NotificationResponse;
import com.nikao.ordemservico.repository.OrdemServicoRepository;
import com.nikao.ordemservico.service.CurrentUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/notifications")
public class NotificationController {

    @Autowired
    private OrdemServicoRepository ordemServicoRepository;

    @Autowired
    private CurrentUserService currentUserService;

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
