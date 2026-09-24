package com.fenglin.springboottest.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 登录入参，对应前端 LoginCard.vue 提交的 JSON：
 * <pre>{"username":"xxx","password":"xxx"}</pre>
 *
 * <p>username 字段允许填用户名或邮箱（页面提示为“用户名 / 邮箱”）。
 */
public class LoginRequest {

    @NotBlank(message = "请输入用户名")
    private String username;

    @NotBlank(message = "请输入密码")
    private String password;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
