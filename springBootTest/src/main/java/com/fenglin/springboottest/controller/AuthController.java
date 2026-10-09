package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * 认证接口：登录 / 注册，供 Vue 前端调用
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserService userService;

    /**
     * 登录
     * 请求体：{"username": "xxx", "password": "xxx"}（username 支持用户名或邮箱）
     */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");
        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            return Result.error(400, "用户名和密码不能为空");
        }

        User user = userService.login(username.trim(), password);
        if (user == null) {
            return Result.error(401, "用户名或密码错误");
        }

        Map<String, Object> data = new HashMap<>();
        data.put("token", UUID.randomUUID().toString().replace("-", ""));
        data.put("user", user);
        return Result.success("登录成功", data);
    }

    /**
     * 注册
     * 请求体：{"username": "xxx", "email": "xxx", "password": "xxx"}
     */
    @PostMapping("/register")
    public Result<Map<String, Object>> register(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String email = body.get("email");
        String password = body.get("password");
        if (username == null || username.isBlank()
                || email == null || email.isBlank()
                || password == null || password.length() < 6) {
            return Result.error(400, "参数不完整或密码不足 6 位");
        }

        User user;
        try {
            user = userService.register(username.trim(), email.trim(), password);
        } catch (IllegalArgumentException e) {
            return Result.error(409, e.getMessage());
        }

        Map<String, Object> data = new HashMap<>();
        data.put("token", UUID.randomUUID().toString().replace("-", ""));
        data.put("user", user);
        return Result.success("注册成功", data);
    }
}
