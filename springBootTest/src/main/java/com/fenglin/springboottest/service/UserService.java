package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fenglin.springboottest.dto.LoginRequest;
import com.fenglin.springboottest.dto.RegisterRequest;
import com.fenglin.springboottest.entity.User;

/**
 * 用户业务接口。
 */
public interface UserService extends IService<User> {

    /**
     * 用户注册：校验唯一性 -> BCrypt 加密密码 -> 落库 -> 下发令牌。
     *
     * @param request 注册参数
     * @return 已保存的用户（含 id 与 token）
     */
    User register(RegisterRequest request);

    /**
     * 用户登录：支持用户名或邮箱登录。
     *
     * @param request 登录参数
     * @return 登录成功的用户（token 已刷新）
     */
    User login(LoginRequest request);
}
