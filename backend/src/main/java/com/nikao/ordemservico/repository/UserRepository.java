package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);

    List<User> findByCompanyId(java.util.UUID companyId);

    List<User> findByCompanyIdAndRoleIn(java.util.UUID companyId, List<com.nikao.ordemservico.domain.Role> roles);

    @Query("""
            select u from User u
            where lower(u.name) like lower(concat('%', :query, '%'))
               or lower(u.email) like lower(concat('%', :query, '%'))
            """)
    List<User> searchUsers(@Param("query") String query);
}
