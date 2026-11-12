package com.fenglin.springboottest.common;

/**
 * 社区功能（论坛 / 好友）统一取当前登录用户。
 * token 由 AuthTokens 内存表管理，与现有登录体系保持一致。
 */
public final class CurrentUser {

    private CurrentUser() {
    }

    /** 从 Authorization 头解析当前登录信息，未登录或过期返回 null */
    public static AuthTokens.Entry get(String authorization) {
        return AuthTokens.get(TokenUtils.extractToken(authorization));
    }

    /** 解析 Long 型参数，兼容前端传数字或字符串 */
    public static Long toLong(Object value) {
        if (value == null) return null;
        if (value instanceof Number n) return n.longValue();
        try {
            return Long.parseLong(String.valueOf(value).trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
