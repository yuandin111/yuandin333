package com.fenglin.springboottest.config;

import com.fenglin.springboottest.common.JwtUtil;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * 注册登录拦截器。
 *
 * <p>保护 /auth/me 与 /user/**，但排除旧的 Thymeleaf 演示页面（/user/to_login 等），
 * 避免这些无需登录的页面被拦截。
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    private final JwtUtil jwtUtil;

    public WebConfig(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new AuthInterceptor(jwtUtil))
                .addPathPatterns("/auth/me", "/user/**")
                .excludePathPatterns(
                        "/user/to_login",
                        "/user/login",
                        "/user/to_index",
                        "/user/test"
                );
    }
}
