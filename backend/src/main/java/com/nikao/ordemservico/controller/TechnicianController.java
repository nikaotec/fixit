package com.nikao.ordemservico.controller;

import com.nikao.ordemservico.domain.FavoriteTechnician;
import com.nikao.ordemservico.domain.Role;
import com.nikao.ordemservico.domain.StatusOrdem;
import com.nikao.ordemservico.domain.User;
import com.nikao.ordemservico.domain.TechnicianReview;
import com.nikao.ordemservico.dto.TechnicianResponse;
import com.nikao.ordemservico.dto.TechnicianReviewRequest;
import com.nikao.ordemservico.repository.FavoriteTechnicianRepository;
import com.nikao.ordemservico.repository.OrdemServicoRepository;
import com.nikao.ordemservico.repository.TechnicianReviewRepository;
import com.nikao.ordemservico.repository.UserRepository;
import com.nikao.ordemservico.service.CurrentUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/technicians")
public class TechnicianController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private FavoriteTechnicianRepository favoriteTechnicianRepository;

    @Autowired
    private OrdemServicoRepository ordemServicoRepository;

    @Autowired
    private TechnicianReviewRepository technicianReviewRepository;

    @Autowired
    private CurrentUserService currentUserService;

    @GetMapping
    public List<TechnicianResponse> getAllTechnicians() {
        var current = currentUserService.getCurrentUser();
        var users = userRepository.findAll();
        return users.stream()
                .filter(user -> !user.getId().equals(current.getId()))
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @GetMapping("/search")
    public List<TechnicianResponse> searchTechnicians(@RequestParam("q") String query) {
        if (query == null || query.trim().length() < 3) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Consulta deve ter ao menos 3 letras"
            );
        }
        var current = currentUserService.getCurrentUser();
        var users = userRepository.searchUsers(
                query.trim()
        );
        return users.stream()
                .filter(user -> !user.getId().equals(current.getId()))
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @GetMapping("/favorites")
    public List<Long> getFavorites() {
        var current = currentUserService.getCurrentUser();
        return favoriteTechnicianRepository.findByUserId(current.getId())
                .stream()
                .map(fav -> fav.getTechnician().getId())
                .collect(Collectors.toList());
    }

    @GetMapping("/favorites/details")
    public List<TechnicianResponse> getFavoriteDetails() {
        var current = currentUserService.getCurrentUser();
        return favoriteTechnicianRepository.findByUserId(current.getId())
                .stream()
                .map(FavoriteTechnician::getTechnician)
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @PostMapping("/{id}/favorite")
    public void addFavorite(@PathVariable Long id) {
        var current = currentUserService.getCurrentUser();
        if (current.getId().equals(id)) {
            throw new IllegalStateException("Nao e possivel favoritar a si mesmo");
        }
        var technician = validateTechnicianForFavorite(id);
        if (favoriteTechnicianRepository.existsByUserIdAndTechnicianId(current.getId(), id)) {
            return;
        }
        FavoriteTechnician fav = new FavoriteTechnician();
        fav.setUser(current);
        fav.setTechnician(technician);
        favoriteTechnicianRepository.save(fav);
    }

    @DeleteMapping("/{id}/favorite")
    public void removeFavorite(@PathVariable Long id) {
        var current = currentUserService.getCurrentUser();
        favoriteTechnicianRepository.findByUserIdAndTechnicianId(current.getId(), id)
                .ifPresent(favoriteTechnicianRepository::delete);
    }

    @PostMapping("/{id}/reviews")
    public void reviewTechnician(@PathVariable Long id, @RequestBody TechnicianReviewRequest request) {
        var current = currentUserService.getCurrentUser();
        if (request.getRating() < 1 || request.getRating() > 5) {
            throw new IllegalStateException("Avaliacao deve estar entre 1 e 5");
        }
        var technician = validateTechnician(current, id);

        TechnicianReview review = new TechnicianReview();
        review.setCompany(current.getCompany());
        review.setTechnician(technician);
        review.setReviewer(current);
        review.setRating(request.getRating());
        review.setComment(request.getComment());
        technicianReviewRepository.save(review);
    }

    private User validateTechnician(User current, Long technicianId) {
        User technician = userRepository.findById(technicianId)
                .orElseThrow(() -> new IllegalStateException("Tecnico nao encontrado"));
        if (technician.getCompany() == null ||
                !technician.getCompany().getId().equals(current.getCompany().getId())) {
            throw new IllegalStateException("Tecnico nao pertence a empresa do usuario");
        }
        if (!(Role.TECNICO.equals(technician.getRole()) || Role.TECHNICIAN.equals(technician.getRole()))) {
            throw new IllegalStateException("Usuario nao e tecnico");
        }
        return technician;
    }

    private User validateTechnicianForFavorite(Long technicianId) {
        User technician = userRepository.findById(technicianId)
                .orElseThrow(() -> new IllegalStateException("Tecnico nao encontrado"));
        return technician;
    }

    private TechnicianResponse toResponse(User user) {
        String status = resolveStatus(user);
        long completed = ordemServicoRepository.countByResponsavelIdAndStatus(
                user.getId(),
                StatusOrdem.FINALIZADA
        );
        Double avg = technicianReviewRepository.averageRating(user.getId());
        double rating = avg != null ? avg : 0.0;
        long reviewCount = technicianReviewRepository.countByTechnicianId(user.getId());
        return new TechnicianResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getRole() != null ? user.getRole().name() : null,
                status,
                rating,
                completed,
                reviewCount,
                null
        );
    }

    private String resolveStatus(User user) {
        if (!user.isActive()) {
            return "offline";
        }
        boolean busy = ordemServicoRepository.existsByResponsavelIdAndStatus(
                user.getId(),
                StatusOrdem.EM_ANDAMENTO
        );
        if (busy) {
            return "busy";
        }
        return "available";
    }
}
