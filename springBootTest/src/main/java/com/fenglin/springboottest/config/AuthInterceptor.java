package com.fenglin.springboottest.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fenglin.springboottest.common.JwtUtil;
import com.fenglin.springboottest.common.Result;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 登录拦截器：校验请求头中的 JWT，通过后把用户信息放进 request，供控制器使用。
 *
 * <p>请求头写法（二选一）：
 * <pre>
 *   Authorization: Bearer &lt;token&gt;
 *   X-Token: &lt;token&gt;
 * </pre>
 */
public class AuthInterceptor implements HandlerInterceptor {

    /** 控制器通过 request.getAttribute 取当前用户 ID */
    public static final String ATTR_USER_ID = "userId";
    public static final String ATTR_USERNAME = "username";

    private final JwtUtil jwtUtil;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AuthInterceptor(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        // 跨域预检请求直接放行
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String token = resolveToken(request);
        if (token == null) {
            writeUnauthorized(response, "未登录，请先登录");
            return false;
        }

        try {
            Claims claims = jwtUtil.parseClaims(token);
            request.setAttribute(ATTR_USER_ID, Long.valueOf(claims.getSubject()));
            request.setAttribute(ATTR_USERNAME, claims.get("username", String.class));
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            writeUnauthorized(response, "登录已失效，请重新登录");
            return false;
        }
    }

    private String resolveToken(HttpServletRequest request) {
        String header = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (header != null && !header.isBlank()) {
            if (header.startsWith("Bearer ")) {
                return header.substring(7).trim();
            }
            return header.trim();
        }
        return request.getHeader("X-Token");
    }

    private void writeUnauthorized(HttpServletResponse response, String message) throws Exception {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");
        objectMapper.writeValue(response.getWriter(), Result.fail(401, message));
    }
}
