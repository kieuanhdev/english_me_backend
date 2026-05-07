package com.kiovant.englishme.dto;

public record CreateDeskRequest(
        String cefrLevel,
        String title,
        Integer sortOrder
) {}
