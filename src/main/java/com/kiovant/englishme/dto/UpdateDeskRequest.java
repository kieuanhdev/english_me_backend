package com.kiovant.englishme.dto;

public record UpdateDeskRequest(
        String cefrLevel,
        String title,
        Integer sortOrder
) {}
