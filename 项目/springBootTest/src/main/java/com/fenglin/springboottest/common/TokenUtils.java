package com.fenglin.springboottest.common;

/**
 * Token 解析工具：从 Authorization 头中提取 token（支持 "Bearer xxx" 或裸 token）。
 * 抽到公共包，避免拦截器反向依赖 AuthController。
 */
public final class TokenUtils {

    private TokenUtils() {
    }

    public static String extractToken(String authorization) {
        if (authorization == null || authorization.isBlank()) {
            return null;
        }
        String value = authorization.trim();
        return value.regionMatches(true, 0, "Bearer ", 0, 7) ? value.substring(7).trim() : value;
    }
}
