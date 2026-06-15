package com.kiovant.englishme.dto;

/**
 * 1 câu dictation trả cho client. {@code text} = đáp án (client chấm so khớp
 * chuẩn hóa); {@code audioUrl} thường null → client dùng TTS đọc {@code text}.
 */
public record DictationSentenceResponse(
        String id,
        String level,
        String text,
        String hint,
        String audioUrl
) {
}
