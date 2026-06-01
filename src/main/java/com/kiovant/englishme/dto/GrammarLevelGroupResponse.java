package com.kiovant.englishme.dto;

import java.util.List;

public record GrammarLevelGroupResponse(
        String level,
        List<GrammarTopicResponse> topics
) {}
