package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.UserMapper;
import com.fenglin.springboottest.service.UserService;
import org.springframework.stereotype.Service;
import org.springframework.util.DigestUtils;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;

/**
 * 用户服务实现类
 */
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Override
    public User register(String username, String email, String password) {
        // 校验用户名是否已存在
        long count = this.count(new LambdaQueryWrapper<User>().eq(User::getUsername, username));
        if (count > 0) {
            throw new IllegalArgumentException("用户名已存在");
        }
        // 校验邮箱是否已存在
        count = this.count(new LambdaQueryWrapper<User>().eq(User::getEmail, email));
        if (count > 0) {
            throw new IllegalArgumentException("邮箱已被注册");
        }

        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(md5(password));
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        this.save(user);

        user.setPassword(null);
        return user;
    }

    @Override
    public User login(String account, String password) {
        // 支持用户名或邮箱登录
        User user = this.getOne(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, account)
                .or()
                .eq(User::getEmail, account)
                .last("limit 1"));

        if (user == null || !user.getPassword().equals(md5(password))) {
            return null;
        }
        user.setPassword(null);
        return user;
    }

    /**
     * MD5 加密
     */
    private String md5(String text) {
        return DigestUtils.md5DigestAsHex(text.getBytes(StandardCharsets.UTF_8));
    }
}
