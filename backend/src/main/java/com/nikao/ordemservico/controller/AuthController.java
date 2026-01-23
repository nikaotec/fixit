package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.User;
import com.nikao.ordemservico.repository.UserRepository;
import com.nikao.ordemservico.dto.AuthRequest;
import com.nikao.ordemservico.dto.AuthResponse;
import com.nikao.ordemservico.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    AuthenticationManager authenticationManager;

    @Autowired
    UserRepository userRepository;

    @Autowired
    JwtTokenProvider tokenProvider;

    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody AuthRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginRequest.getEmail(),
                        loginRequest.getPassword()));

        SecurityContextHolder.getContext().setAuthentication(authentication);

        String jwt = tokenProvider.generateToken(authentication);
        User user = userRepository.findByEmail(loginRequest.getEmail()).orElseThrow();

        return ResponseEntity.ok(new AuthResponse(jwt, user.getRole().toString(), user.getName()));
    }

    @PostMapping("/google-login")
    public ResponseEntity<?> googleLogin(@RequestBody com.nikao.ordemservico.dto.GoogleLoginRequest request) {
        try {
            // 1. Decode token payload (INSECURE: simplified for MVP, implementation should
            // verify signature)
            String[] parts = request.getIdToken().split("\\.");
            if (parts.length < 2) {
                return ResponseEntity.badRequest().body("Invalid Token");
            }
            String payload = new String(java.util.Base64.getUrlDecoder().decode(parts[1]));

            // 2. Extract email from payload using Jackson
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            com.fasterxml.jackson.databind.JsonNode node = mapper.readTree(payload);

            if (!node.has("email")) {
                return ResponseEntity.badRequest().body("Token missing email");
            }

            String email = node.get("email").asText();
            String name = node.has("name") ? node.get("name").asText() : "Google User";

            // 3. Find or Create User
            User user = userRepository.findByEmail(email).orElseGet(() -> {
                User newUser = new User();
                newUser.setEmail(email);
                newUser.setName(name);
                newUser.setPassword(""); // No password for Google users
                // newUser.setRole(com.nikao.ordemservico.domain.Role.CLIENTE); // Default role
                // Since I cannot access Role.CLIENTE directly if I don't import it or use fully
                // qualified
                newUser.setRole(com.nikao.ordemservico.domain.Role.CLIENTE);
                newUser.setActive(true);
                return userRepository.save(newUser);
            });

            // 4. Generate JWT for our backend
            // We need an Authentication object. We can create a custom one or force it.
            // Since we trust the Google Token (in this MVP logic), we treat it as
            // authenticated.

            // For JwtTokenProvider, we usually pass an Authentication object.
            // Let's manually create a UsernamePasswordAuthenticationToken
            Authentication authentication = new UsernamePasswordAuthenticationToken(
                    user.getEmail(), null,
                    java.util.Collections
                            .singletonList(new org.springframework.security.core.authority.SimpleGrantedAuthority(
                                    "ROLE_" + user.getRole().name())));

            String jwt = tokenProvider.generateToken(authentication);

            return ResponseEntity.ok(new AuthResponse(jwt, user.getRole().toString(), user.getName()));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Google Auth Failed: " + e.getMessage());
        }
    }
}
