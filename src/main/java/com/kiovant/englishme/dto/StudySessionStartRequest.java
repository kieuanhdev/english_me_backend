package com.kiovant.englishme.dto;

import java.util.UUID;

/**
 * Body của POST /api/study-sessions/start.
 * limit null -> service dùng default (20). Thay cho Map&lt;String,Object&gt; parse tay.
 */
public record StudySessionStartRequest(
        UUID deskId,
        Integer limit
) {}
