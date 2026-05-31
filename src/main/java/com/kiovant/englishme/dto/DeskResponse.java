package com.kiovant.englishme.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DeskResponse {
    private UUID id;
    private String cefrLevel;
    private String title;
    private Integer sortOrder;
    private LocalDateTime createdAt;
    private long flashcardCount;
    /** true nếu là bộ thẻ hệ thống (owner = null) — FE ẩn sửa/xoá, gắn nhãn "Hệ thống". */
    @JsonProperty("isSystem")
    private boolean system;
}
