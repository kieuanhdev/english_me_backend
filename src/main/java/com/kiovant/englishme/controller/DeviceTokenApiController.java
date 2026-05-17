package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.DeviceTokenRequest;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.service.AdminNotificationService;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/users/me/devices")
public class DeviceTokenApiController {

    private final FirebaseAuthHelper authHelper;
    private final UserRepository userRepository;
    private final AdminNotificationService notificationService;

    public DeviceTokenApiController(FirebaseAuthHelper authHelper,
                                    UserRepository userRepository,
                                    AdminNotificationService notificationService) {
        this.authHelper = authHelper;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
    }

    @PostMapping
    public ResponseEntity<Void> register(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody DeviceTokenRequest req) {
        FirebaseToken fb = authHelper.verifyBearer(authorization);
        User user = userRepository.findByFirebaseUid(fb.getUid())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        notificationService.registerDeviceToken(user, req.token(), req.platform());
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> unregister(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody DeviceTokenRequest req) {
        authHelper.verifyBearer(authorization);
        notificationService.unregisterDeviceToken(req.token());
        return ResponseEntity.noContent().build();
    }
}
