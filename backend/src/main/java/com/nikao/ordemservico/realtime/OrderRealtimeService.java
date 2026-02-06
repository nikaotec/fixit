package com.nikao.ordemservico.realtime;

import com.nikao.ordemservico.domain.OrdemServico;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class OrderRealtimeService {

    @Autowired
    private OrderRealtimeHandler handler;

    public void broadcastOrderUpdate(OrdemServico ordem) {
        if (ordem == null || ordem.getCompany() == null) return;
        UUID companyId = ordem.getCompany().getId();
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", "order_updated");
        payload.put("orderId", ordem.getId());
        payload.put("status", ordem.getStatus() != null ? ordem.getStatus().name() : null);
        payload.put("companyId", companyId.toString());
        payload.put("timestamp", Instant.now().toString());
        handler.broadcast(companyId, payload);
    }
}
