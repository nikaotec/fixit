package com.nikao.ordemservico.realtime;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.nikao.ordemservico.domain.User;
import com.nikao.ordemservico.repository.UserRepository;
import com.nikao.ordemservico.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.net.URI;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class OrderRealtimeHandler extends TextWebSocketHandler {

    private static class SessionInfo {
        private final WebSocketSession session;
        private final UUID companyId;

        private SessionInfo(WebSocketSession session, UUID companyId) {
            this.session = session;
            this.companyId = companyId;
        }
    }

    private final Map<String, SessionInfo> sessions = new ConcurrentHashMap<>();

    @Autowired
    private JwtTokenProvider tokenProvider;

    @Autowired
    private UserRepository userRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        String token = extractToken(session.getUri());
        if (token == null || !tokenProvider.validateToken(token)) {
            session.close(CloseStatus.NOT_ACCEPTABLE.withReason("Token invalido"));
            return;
        }
        String username = tokenProvider.getUserUsernameFromJWT(token);
        User user = userRepository.findByEmail(username).orElse(null);
        if (user == null || user.getCompany() == null) {
            session.close(CloseStatus.NOT_ACCEPTABLE.withReason("Usuario invalido"));
            return;
        }
        sessions.put(session.getId(), new SessionInfo(session, user.getCompany().getId()));
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        sessions.remove(session.getId());
    }

    public void broadcast(UUID companyId, Map<String, Object> payload) {
        TextMessage message;
        try {
            message = new TextMessage(objectMapper.writeValueAsString(payload));
        } catch (Exception e) {
            return;
        }
        sessions.values().forEach(info -> {
            if (!info.session.isOpen()) return;
            if (!info.companyId.equals(companyId)) return;
            try {
                info.session.sendMessage(message);
            } catch (Exception ignored) {
            }
        });
    }

    private String extractToken(URI uri) {
        if (uri == null || uri.getQuery() == null) return null;
        String[] pairs = uri.getQuery().split("&");
        for (String pair : pairs) {
            String[] kv = pair.split("=", 2);
            if (kv.length == 2 && kv[0].equals("token")) {
                return kv[1];
            }
        }
        return null;
    }
}
