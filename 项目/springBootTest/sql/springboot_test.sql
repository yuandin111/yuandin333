-- =====================================================
-- springBootTest 项目数据库初始化脚本
-- 数据库：MySQL 8.0
-- 账号：root / 123456
-- 说明：创建数据库 springboot_test 及用户表 sys_user，并插入一条测试数据
-- 测试账号：admin / 123456
-- =====================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS springboot_test
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE springboot_test;

-- 用户表（幂等：已存在则跳过，不会清空已有数据）
CREATE TABLE IF NOT EXISTS sys_user (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    username    VARCHAR(50)  NOT NULL COMMENT '用户名',
    email       VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    password    VARCHAR(100) NOT NULL COMMENT '密码（明文存储）',
    role        VARCHAR(20)  NOT NULL DEFAULT 'user' COMMENT '角色：admin管理员 / user普通用户（保留字段，权限以 permission 为准）',
    permission  INT          NOT NULL DEFAULT 1 COMMENT '权限：0管理员权限 / 1默认权限（注册用户默认 1）',
    create_time DATETIME     DEFAULT NULL COMMENT '创建时间',
    update_time DATETIME     DEFAULT NULL COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_email (email)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT ='用户表';

-- 兼容已有库：permission 字段不存在时自动补上（幂等，可重复执行）
SET @db_name = DATABASE();
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'sys_user' AND COLUMN_NAME = 'permission'
);
SET @ddl = IF(@col_exists = 0,
    'ALTER TABLE sys_user ADD COLUMN permission INT NOT NULL DEFAULT 1 COMMENT ''权限：0管理员权限 / 1默认权限（注册用户默认 1）'' AFTER role',
    'DO 0');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 插入管理员账号（密码明文 123456，管理员权限 0；INSERT IGNORE 保证重复执行不会覆盖/报错）
-- 全新部署时，请再执行 sql/upgrade_admin_20261026.sql 以创建后台管理所需的内容表与种子数据
INSERT IGNORE INTO sys_user (username, email, password, role, permission, create_time, update_time)
VALUES ('admin', 'admin@test.com', '123456', 'admin', 0, NOW(), NOW());

-- 老数据迁移：原 MD5 密码纠正为明文；并确保 admin 固定为管理员权限（0）
UPDATE sys_user SET password = '123456'
WHERE username = 'admin' AND password = 'e10adc3949ba59abbe56e057f20f883e';
UPDATE sys_user SET permission = 0 WHERE username = 'admin';
