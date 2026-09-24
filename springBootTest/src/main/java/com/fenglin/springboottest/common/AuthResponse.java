package com.fenglin.springboottest.common;

import com.fenglin.springboottest.dto.UserVO;

/**
 * 认证接口（注册 / 登录）的响应体。
 *
 * <p>与前端 auth.js 的约定保持一致：
 * <pre>
 *   成功 -> HTTP 200 {"code":200,"message":"注册成功","token":"xxx","user":{...}}
 *   失败 -> HTTP 4xx {"code":409,"message":"用户名已被注册","data":null}
 * </pre>
 * 前端成功时取 res.token / res.user，失败时取 error.response.data.message。
 */
public class AuthResponse {

    private int code;

    private String message;

    private String token;

    private UserVO user;

    public AuthResponse() {
    }

    public AuthResponse(int code, String message, String token, UserVO user) {
        this.code = code;
        this.message = message;
        this.token = token;
        this.user = user;
    }

    public static AuthResponse success(String message, String token, UserVO user) {
        return new AuthResponse(200, message, token, user);
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public UserVO getUser() {
        return user;
    }

    public void setUser(UserVO user) {
        this.user = user;
    }
}
