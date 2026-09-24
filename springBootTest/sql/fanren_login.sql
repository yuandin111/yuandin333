-- =====================================================================
--  凡人登录 fanren-login  ——  建库建表脚本
--  适用：MySQL 5.7+ / MySQL 8.0+
--  执行方式：
--     mysql -u root -p < sql/fanren_login.sql
--   或在 IDEA / Navicat / DataGrip 中打开后全量执行
-- =====================================================================

-- 1. 创建数据库
CREATE DATABASE IF NOT EXISTS `fanren_login`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE `fanren_login`;

-- 2. 创建用户表
DROP TABLE IF EXISTS `t_user`;
CREATE TABLE `t_user` (
  `id`              BIGINT       NOT NULL AUTO_INCREMENT                       COMMENT '主键 ID',
  `username`        VARCHAR(50)  NOT NULL                                      COMMENT '用户名（唯一）',
  `password`        VARCHAR(100) NOT NULL                                      COMMENT '密码（BCrypt 密文，定长 60）',
  `email`           VARCHAR(100) NOT NULL                                      COMMENT '邮箱（唯一）',
  `nickname`        VARCHAR(50)  DEFAULT NULL                                  COMMENT '昵称',
  `status`          TINYINT      NOT NULL DEFAULT 1                            COMMENT '状态：1-正常，0-禁用',
  `create_time`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP            COMMENT '创建时间',
  `update_time`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email`    (`email`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT = '用户表';

-- 3. （可选）初始化一条测试账号：用户名 admin，密码 123456
--    注册接口会自动写入数据，此步非必须
-- INSERT INTO `t_user` (`username`, `password`, `email`, `nickname`, `status`)
-- VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'admin@fanren.com', '管理员', 1);

-- 4. 登录令牌改用 JWT（无状态），不再需要落库的 token 字段。
--    若此前已按旧版脚本建过表，执行下面两条语句完成迁移：
-- ALTER TABLE `t_user` DROP INDEX `idx_token`;
-- ALTER TABLE `t_user` DROP COLUMN `token`, DROP COLUMN `token_expire_at`;
