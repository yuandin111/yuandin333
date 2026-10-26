package com.fenglin.springboottest.interceptor;

import com.fenglin.springboottest.common.AuthTokens;
import com.fenglin.springboottest.controller.AuthController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * 后台管理接口拦截器：/api/admin/** 必须携带有效 token 且角色为 admin
 */
@Component
public class AdminAuthInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws IOException {
        String token = AuthController.extractToken(request.getHeader("Authorization"));
        AuthTokens.Entry entry = AuthTokens.get(token);

        if (entry == null) {
            writeError(response, 401, "未登录或登录已过期，请重新登录后台");
            return false;
        }
        if (!"admin".equals(entry.role())) {
            writeError(response, 403, "无权限访问后台管理接口");
            return false;
        }
        // 把当前登录用户名放进 request，便于后续审计日志使用
        request.setAttribute("adminUser", entry.username());
        return true;
    }

    private void writeError(HttpServletResponse response, int code, String message) throws IOException {
        response.setStatus(200); // 统一返回体约定：业务错误码放在 body 里，HTTP 状态固定 200
        response.setContentType("application/json;charset=UTF-8");
        String json = "{\"code\":" + code + ",\"message\":\"" + message + "\",\"data\":null}";
        response.getOutputStream().write(json.getBytes(StandardCharsets.UTF_8));
    }
}
