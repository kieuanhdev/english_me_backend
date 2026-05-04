package com.kiovant.englishme.dto;

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
}
