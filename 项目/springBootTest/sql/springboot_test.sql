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

-- 用户表
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    username    VARCHAR(50)  NOT NULL COMMENT '用户名',
    email       VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    password    VARCHAR(100) NOT NULL COMMENT '密码（MD5加密）',
    create_time DATETIME     DEFAULT NULL COMMENT '创建时间',
    update_time DATETIME     DEFAULT NULL COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_email (email)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT ='用户表';

-- 插入测试数据（密码为 123456 的 MD5 值）
INSERT INTO sys_user (username, email, password, create_time, update_time)
VALUES ('admin', 'admin@test.com', 'e10adc3949ba59abbe56e057f20f883e', NOW(), NOW());
