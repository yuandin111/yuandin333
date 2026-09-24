package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.common.BusinessException;
import com.fenglin.springboottest.dto.LoginRequest;
import com.fenglin.springboottest.dto.RegisterRequest;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.UserMapper;
import com.fenglin.springboottest.service.UserService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 用户业务实现。
 *
 * <p>令牌签发由 Controller 层调用 {@link com.fenglin.springboottest.common.JwtUtil} 完成，
 * Service 只负责用户数据的校验与落库。
 */
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    private final BCryptPasswordEncoder passwordEncoder;

    public UserServiceImpl(BCryptPasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public User register(RegisterRequest request) {
        String username = request.getUsername().trim();
        String email = request.getEmail().trim();

        // 1. 唯一性校验（数据库层面也有唯一索引兜底）
        Long usernameCount = baseMapper.selectCount(
                new LambdaQueryWrapper<User>().eq(User::getUsername, username));
        if (usernameCount != null && usernameCount > 0) {
            throw new BusinessException(409, "用户名已被注册");
        }

        Long emailCount = baseMapper.selectCount(
                new LambdaQueryWrapper<User>().eq(User::getEmail, email));
        if (emailCount != null && emailCount > 0) {
            throw new BusinessException(409, "邮箱已被注册");
        }

        // 2. 组装用户，密码使用 BCrypt 加密后入库
        LocalDateTime now = LocalDateTime.now();
        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setNickname(username);
        user.setStatus(1);
        user.setCreateTime(now);
        user.setUpdateTime(now);

        baseMapper.insert(user);
        return user;
    }

    @Override
    public User login(LoginRequest request) {
        String account = request.getUsername().trim();

        // 用户名或邮箱均可登录
        User user = baseMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, account)
                .or()
                .eq(User::getEmail, account)
                .last("LIMIT 1"));

        if (user == null) {
            throw new BusinessException(401, "用户名或密码错误");
        }
        if (user.getStatus() != null && user.getStatus() == 0) {
            throw new BusinessException(403, "账号已被禁用，请联系管理员");
        }
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException(401, "用户名或密码错误");
        }

        user.setUpdateTime(LocalDateTime.now());
        baseMapper.updateById(user);
        return user;
    }
}
