package com.nikao.ordemservico.service;

import com.nikao.ordemservico.domain.Company;
import com.nikao.ordemservico.domain.User;
import com.nikao.ordemservico.repository.CompanyRepository;
import com.nikao.ordemservico.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class CurrentUserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CompanyRepository companyRepository;

    public User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized");
        }
        String email = auth.getName();
        User user = userRepository.findByEmail(email).orElseThrow();
        if (user.getCompany() == null) {
            Company company = new Company();
            String companyName = (user.getName() == null || user.getName().isBlank())
                    ? user.getEmail()
                    : user.getName();
            company.setName(companyName);
            companyRepository.save(company);
            user.setCompany(company);
            userRepository.save(user);
        }
        return user;
    }
}
