package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "app_config")
@Data
public class AppConfig {

    @Id
    @Column(name = "config_key", length = 100)
    private String configKey;

    @Column(name = "config_value", columnDefinition = "TEXT")
    private String configValue;

    /** boolean | integer | string | json */
    @Column(name = "value_type", nullable = false, length = 20)
    private String valueType;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "is_secret", nullable = false)
    private Boolean isSecret = Boolean.FALSE;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "updated_by_email", length = 255)
    private String updatedByEmail;
}
