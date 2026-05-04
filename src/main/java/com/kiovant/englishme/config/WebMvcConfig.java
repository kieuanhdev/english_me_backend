package com.kiovant.englishme.config;

import com.kiovant.englishme.interceptor.AdminRoleInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Autowired
    private AdminRoleInterceptor adminRoleInterceptor;

    /** file:/abs/path/audio/ — khớp audio_url dạng audio/foo.mp3 → GET /audio/foo.mp3 */
    @Value("${englishme.audio.filesystem-root:}")
    private String audioFilesystemRoot;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(adminRoleInterceptor)
                .addPathPatterns("/admin/**")
                .excludePathPatterns("/admin/login");
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        if (audioFilesystemRoot == null || audioFilesystemRoot.isBlank()) {
            return;
        }
        String root = audioFilesystemRoot.trim();
        if (!root.endsWith("/")) {
            root = root + "/";
        }
        if (!root.startsWith("file:")) {
            root = "file:" + root;
        }
        registry.addResourceHandler("/audio/**").addResourceLocations(root);
    }
}
