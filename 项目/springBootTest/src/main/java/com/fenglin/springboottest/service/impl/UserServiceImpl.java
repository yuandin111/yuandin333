package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.UserMapper;
import com.fenglin.springboottest.service.UserService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 用户服务实现类
 * 说明：密码 BCrypt 加密存储（旧明文密码在首次登录时自动升级为密文）；权限统一以 User.permission 为准（0 = 管理员权限 / 1 = 默认权限）
 */
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    private static final BCryptPasswordEncoder ENCODER = new BCryptPasswordEncoder();

    @Override
    public User register(String username, String email, String password) {
        // 校验用户名是否已存在
        long count = this.count(new LambdaQueryWrapper<User>().eq(User::getUsername, username));
        if (count > 0) {
            throw new IllegalArgumentException("用户名已存在");
        }
        // 邮箱改为选填：注册页不再收集邮箱，为空时跳过校验、落库为 null
        boolean hasEmail = email != null && !email.isBlank();
        if (hasEmail) {
            count = this.count(new LambdaQueryWrapper<User>().eq(User::getEmail, email));
            if (count > 0) {
                throw new IllegalArgumentException("邮箱已被注册");
            }
        }

        User user = new User();
        user.setUsername(username);
        user.setEmail(hasEmail ? email.trim() : null);
        user.setPassword(ENCODER.encode(password));
        user.setRole("user");
        user.setPermission(User.PERMISSION_DEFAULT); // 注册用户一律为默认权限（1）
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

        if (user == null || password == null) {
            return null;
        }
        String stored = user.getPassword();
        boolean matched;
        if (stored != null && (stored.startsWith("$2a$") || stored.startsWith("$2b$"))) {
            // 已加密：直接校验
            matched = ENCODER.matches(password, stored);
        } else {
            // 旧版明文：比对通过后就地升级为 BCrypt（一次性迁移，下次登录即走加密分支）
            matched = password.equals(stored);
            if (matched && stored != null) {
                user.setPassword(ENCODER.encode(password));
                this.updateById(user);
            }
        }
        if (!matched) {
            return null;
        }
        user.setPassword(null);
        return user;
    }

    /**
     * 判断用户是否具备管理员权限（permission = 0）
     */
    public static boolean isAdmin(User user) {
        return user != null && user.getPermission() != null
                && user.getPermission() == User.PERMISSION_ADMIN;
    }
}
