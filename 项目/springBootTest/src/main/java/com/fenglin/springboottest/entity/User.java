package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户实体类，对应表 sys_user
 */
@Data
@TableName("sys_user")
public class User {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 用户名 */
    private String username;

    /** 邮箱 */
    private String email;

    /** 密码（明文存储，不做加密） */
    private String password;

    /** 角色：admin 管理员 / user 普通用户（保留字段，权限判定统一以 permission 为准） */
    private String role;

    /** 权限：0 = 管理员权限，1 = 默认权限（普通用户） */
    private Integer permission;

    /** 权限常量：管理员权限（可登录并管理后台） */
    public static final int PERMISSION_ADMIN = 0;

    /** 权限常量：默认权限，注册用户默认取该值 */
    public static final int PERMISSION_DEFAULT = 1;

    /** 创建时间 */
    private LocalDateTime createTime;

    /** 更新时间 */
    private LocalDateTime updateTime;
}
