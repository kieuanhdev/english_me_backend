package com.kiovant.englishme.dto;

import lombok.Data;

@Data
public class CreateDeskRequest {
    /** Ví dụ A1, B2 — duy nhất trong hệ thống */
    private String cefrLevel;
    private String title;
    /** Nếu null, gán max(sort_order) + 1 */
    private Integer sortOrder;
}
