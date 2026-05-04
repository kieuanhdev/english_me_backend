package com.kiovant.englishme.dto;

import lombok.Data;

@Data
public class UpdateDeskRequest {
    private String cefrLevel;
    private String title;
    private Integer sortOrder;
}
