package com.fenglin.springboottest.common;

import com.fenglin.springboottest.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

/**
 * JWT 工具类：签发与校验登录令牌。
 *
 * <p>令牌载荷：sub = 用户ID，username = 用户名。
 */
@Component
public class JwtUtil {

    private final SecretKey key;

    /** 有效期（小时） */
    private final long expirationHours;

    public JwtUtil(@Value("${jwt.secret}") String secret,
                   @Value("${jwt.expiration-hours}") long expirationHours) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expirationHours = expirationHours;
    }

    /** 签发令牌 */
    public String generateToken(User user) {
        Date now = new Date();
        Date expire = new Date(now.getTime() + expirationHours * 3600_000L);
        return Jwts.builder()
                .subject(String.valueOf(user.getId()))
                .claim("username", user.getUsername())
                .issuedAt(now)
                .expiration(expire)
                // 显式指定 HS256；否则 jjwt 会按密钥长度自动选算法（长密钥会变成 HS384/HS512）
                .signWith(key, Jwts.SIG.HS256)
                .compact();
    }

    /** 解析令牌，失败抛出 JwtException */
    public Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    /** 判断令牌是否有效（过期、签名错误、格式错误都返回 false） */
    public boolean isValid(String token) {
        try {
            parseClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}
