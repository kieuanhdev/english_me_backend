package com.kiovant.englishme.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Clock;

/**
 * Clock bean dùng chung — service lấy "bây giờ" qua Clock thay vì gọi
 * LocalDate.now()/LocalDateTime.now() trực tiếp. Test inject Clock.fixed(...)
 * để kiểm soát thời gian (streak qua nửa đêm, lịch ôn SM-2, week XP...).
 *
 * UTC khớp với hibernate.jdbc.time_zone=UTC và JVM -Duser.timezone=UTC.
 */
@Configuration
public class ClockConfig {

    @Bean
    public Clock clock() {
        return Clock.systemUTC();
    }
}
