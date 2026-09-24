package com.fenglin.springboottest.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * 注册入参，对应前端 RegisterCard.vue 提交的 JSON：
 * <pre>{"username":"xxx","email":"xxx","password":"xxx"}</pre>
 */
public class RegisterRequest {

    @NotBlank(message = "请输入用户名")
    @Size(min = 2, max = 20, message = "用户名长度需为 2-20 位")
    private String username;

    @NotBlank(message = "请输入邮箱")
    @Email(message = "请输入有效的邮箱地址")
    private String email;

    @NotBlank(message = "请输入密码")
    @Size(min = 6, max = 32, message = "密码长度需为 6-32 位")
    private String password;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
