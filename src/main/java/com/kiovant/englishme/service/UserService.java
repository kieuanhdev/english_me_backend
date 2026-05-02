package com.kiovant.englishme.service;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;


@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;

    public User syncUser(FirebaseToken token) {
        String uid = token.getUid();

        return userRepository.findByFirebaseUid(uid)
                .map(existingUser -> {
                    // Cập nhật thông tin cơ bản từ Firebase
                    existingUser.setFullName((String) token.getClaims().get("name"));
                    existingUser.setAvatarUrl((String) token.getClaims().get("picture"));
                    return userRepository.save(existingUser);
                })
                .orElseGet(() -> {
                    // Tạo mới nếu chưa tồn tại
                    User newUser = new User();
                    newUser.setFirebaseUid(uid);
                    newUser.setEmail(token.getEmail());
                    newUser.setFullName((String) token.getClaims().get("name"));
                    newUser.setAvatarUrl((String) token.getClaims().get("picture"));
                    newUser.setIsOnboarded(false); // Mặc định chưa làm test
                    return userRepository.save(newUser);
                });
    }

    public List<User> findAllUsers() {
        return userRepository.findAll()
                .stream()
                .sorted((u1, u2) -> {
                    LocalDateTime t1 = u1.getCreatedAt() != null ? u1.getCreatedAt() : LocalDateTime.MIN;
                    LocalDateTime t2 = u2.getCreatedAt() != null ? u2.getCreatedAt() : LocalDateTime.MIN;
                    return t2.compareTo(t1);
                })
                .toList();
    }

    public List<User> findUsersByFilter(String cefrLevel, String status, String keyword) {
        String normalizedCefr = cefrLevel == null ? "" : cefrLevel.trim();
        String normalizedStatus = status == null ? "all" : status.trim().toLowerCase(Locale.ROOT);
        String normalizedKeyword = keyword == null ? "" : keyword.trim().toLowerCase(Locale.ROOT);

        return findAllUsers().stream()
                .filter(user -> {
                    if (normalizedCefr.isEmpty()) {
                        return true;
                    }
                    String level = user.getCefrLevel() == null ? "" : user.getCefrLevel().trim();
                    return normalizedCefr.equalsIgnoreCase(level);
                })
                .filter(user -> {
                    if ("all".equals(normalizedStatus)) {
                        return true;
                    }
                    boolean active = user.getIsOnboarded() != null && user.getIsOnboarded();
                    return ("active".equals(normalizedStatus) && active)
                            || ("locked".equals(normalizedStatus) && !active);
                })
                .filter(user -> {
                    if (normalizedKeyword.isEmpty()) {
                        return true;
                    }
                    String fullName = user.getFullName() == null ? "" : user.getFullName().toLowerCase(Locale.ROOT);
                    String email = user.getEmail() == null ? "" : user.getEmail().toLowerCase(Locale.ROOT);
                    String uid = user.getFirebaseUid() == null ? "" : user.getFirebaseUid().toLowerCase(Locale.ROOT);
                    return fullName.contains(normalizedKeyword)
                            || email.contains(normalizedKeyword)
                            || uid.contains(normalizedKeyword);
                })
                .toList();
    }
}