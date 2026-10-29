-- =====================================================
-- 用户权限字段升级脚本（在已有数据库上执行一次即可，支持重复执行）
-- 内容：
--   1. sys_user 新增 permission 权限字段（0 = 管理员权限 / 1 = 默认权限，默认 1）
--   2. admin 账号固定为管理员权限（permission = 0）
--   3. 除 admin 外的用户统一为默认权限（permission = 1）
--   4. 密码改为明文存储（原 123456 的 MD5 值纠正为明文 123456）
-- 说明：
--   - 权限判定：0 = 管理员权限（可登录后台），1 = 默认权限（普通用户，看不到后台按钮）
--   - 注册的新用户一律为默认权限（1）
--   - 通过 information_schema 判断字段是否存在，重复执行不会报“字段已存在”
-- =====================================================

USE springboot_test;

-- ---------- 1. 新增 permission 字段（幂等） ----------
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

-- ---------- 2. admin 设为管理员权限 ----------
UPDATE sys_user SET permission = 0 WHERE username = 'admin';

-- ---------- 3. 其余用户统一为默认权限 ----------
UPDATE sys_user SET permission = 1 WHERE username <> 'admin';

-- ---------- 4. 密码明文化（仅纠正历史 MD5 值，不会覆盖已改过的密码） ----------
UPDATE sys_user SET password = '123456'
WHERE username = 'admin' AND password = 'e10adc3949ba59abbe56e057f20f883e';

-- ---------- 5. 同步字段注释 ----------
ALTER TABLE sys_user MODIFY COLUMN password VARCHAR(100) NOT NULL COMMENT '密码（明文存储）';

-- ---------- 结果自检：应看到 admin 的 permission = 0，其余为 1 ----------
SELECT id, username, password, role, permission FROM sys_user;
