package com.fenglin.springboottest.common;

import com.fenglin.springboottest.entity.User;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 登录 token 内存存储：token -> 用户信息 + 过期时间。
 * 简单实现，重启后失效；生产环境建议换 Redis / JWT。
 */
public class AuthTokens {

    /** token 有效期：12 小时 */
    private static final long EXPIRE_MS = 12 * 60 * 60 * 1000L;

    private static final Map<String, Entry> STORE = new ConcurrentHashMap<>();

    /** token 对应的登录信息 */
    public record Entry(Long userId, String username, String role, long expireAt) {
        public boolean expired() {
            return System.currentTimeMillis() > expireAt;
        }
    }

    /** 登录成功后创建 token */
    public static String create(User user) {
        purgeExpired();
        String token = UUID.randomUUID().toString().replace("-", "");
        STORE.put(token, new Entry(user.getId(), user.getUsername(), user.getRole(),
                System.currentTimeMillis() + EXPIRE_MS));
        return token;
    }

    /** 查询 token 对应的登录信息，无效或过期返回 null */
    public static Entry get(String token) {
        if (token == null || token.isBlank()) {
            return null;
        }
        Entry entry = STORE.get(token);
        if (entry == null) {
            return null;
        }
        if (entry.expired()) {
            STORE.remove(token);
            return null;
        }
        return entry;
    }

    /** 注销 */
    public static void remove(String token) {
        if (token != null) {
            STORE.remove(token);
        }
    }

    private static void purgeExpired() {
        STORE.entrySet().removeIf(e -> e.getValue().expired());
    }
}
