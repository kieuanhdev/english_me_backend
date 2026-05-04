package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "flashcard")
@Data
public class Flashcard {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "desk_id", nullable = false)
    private Desk desk;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String word;

    @Column(nullable = false, length = 10)
    private String cefr;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "pos_json", columnDefinition = "jsonb")
    private List<String> posJson;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "all_levels_json", columnDefinition = "jsonb")
    private List<Map<String, Object>> allLevelsJson;

    @Column(columnDefinition = "TEXT")
    private String ipa;

    @Column(name = "audio_url", columnDefinition = "TEXT")
    private String audioUrl;

    @Column(columnDefinition = "TEXT")
    private String definition;

    @Column(columnDefinition = "TEXT")
    private String example;

    @Column(length = 512)
    private String topic;

    @Column(columnDefinition = "TEXT")
    private String vietnamese;

    @Column(name = "vi_definition", columnDefinition = "TEXT")
    private String viDefinition;

    @Column(name = "vi_example", columnDefinition = "TEXT")
    private String viExample;
}
