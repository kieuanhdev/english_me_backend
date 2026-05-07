package com.kiovant.englishme.service;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.UserRepository;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User syncUser(FirebaseToken token) {
        String uid = token.getUid();

        return userRepository.findByFirebaseUid(uid)
                .map(existingUser -> {
                    requireAccountNotLocked(existingUser);
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
                    newUser.setAccountLocked(false);
                    return userRepository.save(newUser);
                });
    }

    /** Chan API hoc vien khi tai khoan bi admin khoa */
    public void requireAccountNotLocked(User user) {
        if (user != null && Boolean.TRUE.equals(user.getAccountLocked())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Tai khoan da bi khoa");
        }
    }

    public List<User> findAllUsers() {
        return userRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"));
    }

    public List<User> findUsersByFilter(String cefrLevel, String status, String keyword) {
        Specification<User> spec = buildFilterSpec(cefrLevel, status, keyword);
        return userRepository.findAll(spec, Sort.by(Sort.Direction.DESC, "createdAt"));
    }

    private Specification<User> buildFilterSpec(String cefrLevel, String status, String keyword) {
        Specification<User> spec = (root, query, cb) -> cb.conjunction();

        if (cefrLevel != null && !cefrLevel.isBlank()) {
            String level = cefrLevel.trim();
            spec = spec.and((root, query, cb) -> cb.equal(root.get("cefrLevel"), level));
        }

        if (status != null && !status.isBlank()) {
            String s = status.trim().toLowerCase(Locale.ROOT);
            if (!"all".equals(s)) {
                boolean locked = "locked".equals(s);
                spec = spec.and((root, query, cb) -> cb.equal(root.get("accountLocked"), locked));
            }
        }

        if (keyword != null && !keyword.isBlank()) {
            String kw = "%" + keyword.trim().toLowerCase(Locale.ROOT) + "%";
            spec = spec.and((root, query, cb) -> cb.or(
                    cb.like(cb.lower(root.get("fullName")), kw),
                    cb.like(cb.lower(root.get("email")), kw),
                    cb.like(cb.lower(root.get("firebaseUid")), kw)
            ));
        }

        return spec;
    }

    public void unlockUser(UUID id) {
        userRepository.findById(id).ifPresent(user -> {
            user.setAccountLocked(false);
            userRepository.save(user);
        });
    }

    public void lockUser(UUID id) {
        userRepository.findById(id).ifPresent(user -> {
            user.setAccountLocked(true);
            userRepository.save(user);
        });
    }
}
