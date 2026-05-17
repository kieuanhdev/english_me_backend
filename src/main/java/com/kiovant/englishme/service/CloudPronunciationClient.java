package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;

public interface CloudPronunciationClient {

    JsonNode assess(byte[] audioBytes, String referenceText, String language);

    String providerName();
}
