package com.kiovant.englishme.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI englishMeOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("EnglishMe API")
                        .description("REST API của EnglishMe — placement test, flashcard/desk, chat, đồng bộ user Firebase.")
                        .version("1.0"));
    }
}
