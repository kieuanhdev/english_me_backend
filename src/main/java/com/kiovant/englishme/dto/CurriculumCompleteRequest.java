package com.kiovant.englishme.dto;

import java.util.List;
import java.util.Map;

/**
 * Body cho POST /curriculum/lessons/{lessonId}/complete.
 * FE chấm quiz ở client rồi gửi điểm cuối + (optional) đáp án để lưu attempt.
 */
public record CurriculumCompleteRequest(
        Integer score,
        Integer timeSpentSeconds,
        List<Map<String, Object>> answers
) {}
