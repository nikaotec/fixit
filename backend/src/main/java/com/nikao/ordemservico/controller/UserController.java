package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.User;
import com.nikao.ordemservico.repository.UserRepository;
import com.nikao.ordemservico.service.CurrentUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/users")
public class UserController {

    @Autowired
    UserRepository userRepository;

    @Autowired
    PasswordEncoder passwordEncoder;

    @Autowired
    CurrentUserService currentUserService;

    @GetMapping
    public List<User> getAllUsers() {
        var user = currentUserService.getCurrentUser();
        return userRepository.findByCompanyId(user.getCompany().getId());
    }

    @PostMapping
    public User createUser(@RequestBody User user) {
        var current = currentUserService.getCurrentUser();
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setCompany(current.getCompany());
        return userRepository.save(user);
    }

    @GetMapping("/me")
    public User getMe(java.security.Principal principal) {
        String email = principal.getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
