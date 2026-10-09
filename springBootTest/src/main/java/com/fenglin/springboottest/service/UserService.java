package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fenglin.springboottest.entity.User;

/**
 * 用户服务接口
 */
public interface UserService extends IService<User> {

    /**
     * 用户注册
     *
     * @param username 用户名
     * @param email    邮箱
     * @param password 明文密码
     * @return 注册成功的用户（不含密码）
     */
    User register(String username, String email, String password);

    /**
     * 用户登录，支持用户名或邮箱登录
     *
     * @param account  用户名或邮箱
     * @param password 明文密码
     * @return 登录成功的用户（不含密码），失败返回 null
     */
    User login(String account, String password);
}
