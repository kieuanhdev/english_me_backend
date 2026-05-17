package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.AuditLogRow;
import com.kiovant.englishme.entity.AdminAuditLog;
import com.kiovant.englishme.repository.AdminAuditLogRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Service
public class AdminAuditLogService {

    private final AdminAuditLogRepository repo;

    public AdminAuditLogService(AdminAuditLogRepository repo) {
        this.repo = repo;
    }

    @Transactional(readOnly = true)
    public List<AuditLogRow> search(String email, String action, LocalDate from, LocalDate to) {
        String normEmail = blankToNull(email);
        String normAction = action == null || action.isBlank() ? null : action.trim().toUpperCase(Locale.ROOT);
        LocalDateTime fromDt = from == null ? null : from.atStartOfDay();
        LocalDateTime toDt = to == null ? null : to.plusDays(1).atStartOfDay();

        List<AdminAuditLog> rows = repo.search(normEmail, normAction, fromDt, toDt);
        List<AuditLogRow> out = new ArrayList<>(rows.size());
        for (AdminAuditLog r : rows) {
            out.add(new AuditLogRow(
                    r.getId(), r.getAdminEmail(), r.getAction(), r.getRequestUri(),
                    r.getEntityType(), r.getEntityId(), r.getStatusCode(),
                    r.getIpAddress(), r.getCreatedAt()
            ));
        }
        return out;
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
