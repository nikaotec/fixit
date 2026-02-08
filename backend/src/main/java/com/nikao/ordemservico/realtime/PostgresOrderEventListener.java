package com.nikao.ordemservico.realtime;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.postgresql.PGConnection;
import org.postgresql.PGNotification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

@Component
public class PostgresOrderEventListener {

    private static final Logger logger = LoggerFactory.getLogger(PostgresOrderEventListener.class);
    private static final String CHANNEL = "order_events";

    @Autowired
    private DataSource dataSource;

    @Autowired
    private OrderRealtimeHandler orderRealtimeHandler;

    @Autowired
    private ObjectMapper objectMapper;

    private final ExecutorService executor = Executors.newSingleThreadExecutor(r -> {
        Thread t = new Thread(r, "pg-order-events-listener");
        t.setDaemon(true);
        return t;
    });

    private volatile boolean running = true;
    private Connection connection;
    private PGConnection pgConnection;

    @PostConstruct
    public void start() {
        executor.submit(this::listenLoop);
    }

    @PreDestroy
    public void stop() {
        running = false;
        executor.shutdownNow();
        closeConnection();
        try {
            executor.awaitTermination(2, TimeUnit.SECONDS);
        } catch (InterruptedException ignored) {
            Thread.currentThread().interrupt();
        }
    }

    private void listenLoop() {
        while (running) {
            try {
                ensureConnection();
                PGNotification[] notifications = pgConnection.getNotifications(10_000);
                if (notifications == null) {
                    continue;
                }
                for (PGNotification notification : notifications) {
                    handleNotification(notification.getParameter());
                }
            } catch (Exception e) {
                logger.warn("Erro no listener de NOTIFY, tentando reconectar: {}", e.getMessage());
                closeConnection();
                sleepQuietly(2000);
            }
        }
    }

    private void ensureConnection() throws Exception {
        if (connection != null && !connection.isClosed() && pgConnection != null) {
            return;
        }
        connection = dataSource.getConnection();
        connection.setAutoCommit(true);
        pgConnection = connection.unwrap(PGConnection.class);
        try (Statement statement = connection.createStatement()) {
            statement.execute("LISTEN " + CHANNEL);
        }
        logger.info("Escutando canal PostgreSQL: {}", CHANNEL);
    }

    private void handleNotification(String payload) {
        if (payload == null || payload.isBlank()) return;
        try {
            Map<String, Object> data = objectMapper.readValue(payload, new TypeReference<>() {});
            Object companyRaw = data.get("companyId");
            Object orderRaw = data.get("orderId");
            if (companyRaw == null || orderRaw == null) return;
            UUID companyId;
            try {
                companyId = UUID.fromString(companyRaw.toString());
            } catch (Exception e) {
                return;
            }
            Long orderId = parseLong(orderRaw);
            if (orderId == null) return;

            Map<String, Object> event = new HashMap<>();
            Object type = data.get("type");
            String eventType = type != null ? type.toString() : "order_updated";
            event.put("type", eventType);
            event.put("orderId", orderId);
            event.put("companyId", companyId.toString());
            Object ts = data.get("timestamp");
            event.put("timestamp", ts != null ? ts : Instant.now().toString());
            orderRealtimeHandler.broadcast(companyId, event);
            if (logger.isDebugEnabled()) {
                logger.debug("Notificacao PG -> WS: type={} companyId={} orderId={}", eventType, companyId, orderId);
            }
        } catch (Exception ignored) {
            // ignore malformed payloads
        }
    }

    private Long parseLong(Object value) {
        if (value instanceof Number) return ((Number) value).longValue();
        if (value instanceof String) {
            try {
                return Long.parseLong((String) value);
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private void closeConnection() {
        if (connection == null) return;
        try {
            connection.close();
        } catch (Exception ignored) {
        } finally {
            connection = null;
            pgConnection = null;
        }
    }

    private void sleepQuietly(long millis) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException ignored) {
            Thread.currentThread().interrupt();
        }
    }
}
