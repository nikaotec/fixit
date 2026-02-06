package com.nikao.ordemservico.repository;

import com.nikao.ordemservico.domain.UserDevice;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UserDeviceRepository extends JpaRepository<UserDevice, Long> {
    Optional<UserDevice> findByUserIdAndDeviceIdAndActiveTrue(Long userId, String deviceId);

    java.util.List<UserDevice> findByUserIdAndActiveTrue(Long userId);
}
