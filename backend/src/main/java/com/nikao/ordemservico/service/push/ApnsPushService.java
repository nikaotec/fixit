package com.nikao.ordemservico.service.push;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.Signature;
import java.security.spec.PKCS8EncodedKeySpec;
import java.time.Instant;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

@Service
public class ApnsPushService {

    private static final Logger logger = LoggerFactory.getLogger(ApnsPushService.class);

    @Value("${app.apns.team-id:}")
    private String teamId;

    @Value("${app.apns.key-id:}")
    private String keyId;

    @Value("${app.apns.bundle-id:}")
    private String bundleId;

    @Value("${app.apns.private-key:}")
    private String privateKey;

    @Value("${app.apns.use-sandbox:false}")
    private boolean useSandbox;

    @Value("${app.apns.enabled:false}")
    private boolean enabled;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    public void sendNotification(String apnsToken, String title, String body, Map<String, Object> data) {
        if (!enabled) return;
        if (apnsToken == null || apnsToken.isBlank()) return;
        if (teamId.isBlank() || keyId.isBlank() || bundleId.isBlank() || privateKey.isBlank()) {
            return;
        }
        try {
            String jwt = buildJwt();
            String host = useSandbox ? "https://api.sandbox.push.apple.com" : "https://api.push.apple.com";
            URI uri = URI.create(host + "/3/device/" + apnsToken);

            Map<String, Object> payload = new HashMap<>();
            Map<String, Object> aps = new HashMap<>();
            Map<String, Object> alert = new HashMap<>();
            alert.put("title", title);
            alert.put("body", body);
            aps.put("alert", alert);
            aps.put("sound", "default");
            payload.put("aps", aps);
            if (data != null && !data.isEmpty()) {
                payload.putAll(data);
            }

            String json = objectMapper.writeValueAsString(payload);
            HttpRequest request = HttpRequest.newBuilder(uri)
                    .header("authorization", "bearer " + jwt)
                    .header("apns-topic", bundleId)
                    .header("apns-push-type", "alert")
                    .header("apns-priority", "10")
                    .POST(HttpRequest.BodyPublishers.ofString(json, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                logger.warn("APNS push falhou: status={} body={}", response.statusCode(), response.body());
            }
        } catch (Exception e) {
            logger.warn("Erro ao enviar APNS: {}", e.getMessage());
        }
    }

    private String buildJwt() throws Exception {
        String header = base64Url("{\"alg\":\"ES256\",\"kid\":\"" + keyId + "\"}");
        String payload = base64Url("{\"iss\":\"" + teamId + "\",\"iat\":" + Instant.now().getEpochSecond() + "}");
        String unsigned = header + "." + payload;
        byte[] signature = sign(unsigned.getBytes(StandardCharsets.UTF_8));
        return unsigned + "." + Base64.getUrlEncoder().withoutPadding().encodeToString(signature);
    }

    private byte[] sign(byte[] data) throws Exception {
        PrivateKey key = loadPrivateKey();
        Signature signature = Signature.getInstance("SHA256withECDSA");
        signature.initSign(key);
        signature.update(data);
        return signature.sign();
    }

    private PrivateKey loadPrivateKey() throws Exception {
        String clean = privateKey
                .replace("-----BEGIN PRIVATE KEY-----", "")
                .replace("-----END PRIVATE KEY-----", "")
                .replaceAll("\\s", "");
        byte[] keyBytes = Base64.getDecoder().decode(clean);
        PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(keyBytes);
        KeyFactory kf = KeyFactory.getInstance("EC");
        return kf.generatePrivate(spec);
    }

    private String base64Url(String value) {
        return Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(value.getBytes(StandardCharsets.UTF_8));
    }
}
