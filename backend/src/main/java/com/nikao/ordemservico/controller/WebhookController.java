package com.nikao.ordemservico.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/webhook/n8n")
public class WebhookController {

    @PostMapping("/evento")
    public ResponseEntity<String> receiveEvent(@RequestBody Map<String, Object> payload) {
        System.out.println("Received webhook from n8n: " + payload);
        // Process payload logic here
        return ResponseEntity.ok("Received");
    }
}
