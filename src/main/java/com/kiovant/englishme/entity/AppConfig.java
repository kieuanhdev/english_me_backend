package com.kiovant.englishme.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "app_config")
@Getter
@Setter
public class AppConfig {

    @Id
    @Column(name = "config_key", length = 100)
    private String configKey;

    @Column(name = "config_value", columnDefinition = "TEXT")
    private String configValue;

    @Column(name = "value_type", length = 20, nullable = false)
    private String valueType;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "is_secret", nullable = false)
    private boolean secret;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "updated_by_email", length = 255)
    private String updatedByEmail;
}
