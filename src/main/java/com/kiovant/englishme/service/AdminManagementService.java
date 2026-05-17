package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.AdminAccountRow;
import com.kiovant.englishme.entity.AdminAccount;
import com.kiovant.englishme.repository.AdminAccountRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
public class AdminManagementService {

    public static final Set<String> ALLOWED_ROLES = Set.of("SUPER_ADMIN", "EDITOR", "VIEWER");

    private final AdminAccountRepository accountRepo;
    private final SecureRandom rng = new SecureRandom();

    public AdminManagementService(AdminAccountRepository accountRepo) {
        this.accountRepo = accountRepo;
    }

    @Transactional(readOnly = true)
    public List<AdminAccountRow> listAccounts() {
        List<AdminAccount> all = accountRepo.findAllByOrderByCreatedAtDesc();
        List<AdminAccountRow> rows = new ArrayList<>(all.size());
        for (AdminAccount a : all) {
            rows.add(new AdminAccountRow(
                    a.getId(), a.getEmail(), a.getFullName(), a.getRole(),
                    Boolean.TRUE.equals(a.getIsActive()),
                    a.getLastLoginAt(), a.getCreatedAt()
            ));
        }
        return rows;
    }

    @Transactional
    public AdminAccount create(String email, String password, String fullName, String role) {
        String e = requireEmail(email);
        String p = requirePassword(password);
        String r = normalizeRole(role);

        if (accountRepo.existsByEmailIgnoreCase(e)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email đã tồn tại: " + e);
        }

        AdminAccount a = new AdminAccount();
        a.setEmail(e);
        a.setFullName(blankToNull(fullName));
        a.setRole(r);
        a.setIsActive(Boolean.TRUE);
        applyPassword(a, p);
        return accountRepo.save(a);
    }

    @Transactional
    public AdminAccount updateRole(UUID id, String role) {
        AdminAccount a = getOrThrow(id);
        a.setRole(normalizeRole(role));
        return accountRepo.save(a);
    }

    @Transactional
    public String resetPassword(UUID id, String newPassword) {
        AdminAccount a = getOrThrow(id);
        String p = (newPassword == null || newPassword.isBlank())
                ? generatePassword()
                : requirePassword(newPassword);
        applyPassword(a, p);
        accountRepo.save(a);
        return p;
    }

    @Transactional
    public void setActive(UUID id, boolean active) {
        AdminAccount a = getOrThrow(id);
        a.setIsActive(active);
        accountRepo.save(a);
    }

    /** Soft delete = vô hiệu hóa. */
    @Transactional
    public void disable(UUID id) {
        setActive(id, false);
    }

    public AdminAccount getOrThrow(UUID id) {
        return accountRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Admin không tồn tại."));
    }

    // ── Password helpers (SHA-256 + per-account salt) ───────────────────────

    private void applyPassword(AdminAccount a, String rawPassword) {
        String salt = randomSalt();
        a.setPasswordSalt(salt);
        a.setPasswordHash(hash(rawPassword, salt));
    }

    private String randomSalt() {
        byte[] buf = new byte[16];
        rng.nextBytes(buf);
        return HexFormat.of().formatHex(buf);
    }

    private String generatePassword() {
        byte[] buf = new byte[9];
        rng.nextBytes(buf);
        return HexFormat.of().formatHex(buf);
    }

    private static String hash(String password, String salt) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt.getBytes(StandardCharsets.UTF_8));
            byte[] out = md.digest(password.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(out);
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 không khả dụng", ex);
        }
    }

    // ── Validation ──────────────────────────────────────────────────────────

    private static String requireEmail(String email) {
        String trimmed = email == null ? "" : email.trim();
        if (trimmed.isEmpty() || !trimmed.contains("@")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email không hợp lệ.");
        }
        return trimmed.toLowerCase(Locale.ROOT);
    }

    private static String requirePassword(String password) {
        if (password == null || password.length() < 8) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Mật khẩu phải ít nhất 8 ký tự.");
        }
        return password;
    }

    private static String normalizeRole(String role) {
        if (role == null || role.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Role không được trống.");
        }
        String upper = role.trim().toUpperCase(Locale.ROOT);
        if (!ALLOWED_ROLES.contains(upper)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Role không hợp lệ. Cho phép: " + ALLOWED_ROLES);
        }
        return upper;
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
