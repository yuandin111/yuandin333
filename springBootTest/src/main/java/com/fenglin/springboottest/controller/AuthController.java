package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.AuthResponse;
import com.fenglin.springboottest.common.BusinessException;
import com.fenglin.springboottest.common.JwtUtil;
import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.config.AuthInterceptor;
import com.fenglin.springboottest.dto.LoginRequest;
import com.fenglin.springboottest.dto.RegisterRequest;
import com.fenglin.springboottest.dto.UserVO;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 认证接口：注册 / 登录。
 *
 * <p>配合前端 fanren-login-vue 使用，完整路径（context-path 为 /api）：
 * <pre>
 *   POST http://localhost:8081/api/auth/register
 *   POST http://localhost:8081/api/auth/login
 * </pre>
 */
@RestController
@RequestMapping("/auth")
public class AuthController {

    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    private final UserService userService;
    private final JwtUtil jwtUtil;

    public AuthController(UserService userService, JwtUtil jwtUtil) {
        this.userService = userService;
        this.jwtUtil = jwtUtil;
    }

    /**
     * 用户注册
     *
     * @param request {"username":"","email":"","password":""}
     * @return {"code":200,"message":"注册成功","token":"","user":{...}}
     */
    @PostMapping("/register")
    public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        User user = userService.register(request);
        log.info("用户注册成功：id={}, username={}", user.getId(), user.getUsername());
        return AuthResponse.success("注册成功", jwtUtil.generateToken(user), UserVO.from(user));
    }

    /**
     * 用户登录（用户名或邮箱均可）
     *
     * @param request {"username":"","password":""}
     * @return {"code":200,"message":"登录成功","token":"","user":{...}}
     */
    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        User user = userService.login(request);
        log.info("用户登录成功：id={}, username={}", user.getId(), user.getUsername());
        return AuthResponse.success("登录成功", jwtUtil.generateToken(user), UserVO.from(user));
    }

    /**
     * 获取当前登录用户（需要登录）
     *
     * <p>请求头：{@code Authorization: Bearer <token>}
     *
     * @return {"code":200,"message":"success","data":{...用户信息}}
     */
    @GetMapping("/me")
    public Result<UserVO> me(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute(AuthInterceptor.ATTR_USER_ID);
        User user = userService.getById(userId);
        if (user == null) {
            throw new BusinessException(404, "用户不存在");
        }
        return Result.ok(UserVO.from(user));
    }
}
