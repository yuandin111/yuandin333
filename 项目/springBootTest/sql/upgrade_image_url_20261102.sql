-- ============================================================
-- 图文内容升级迁移：为内容三表增加 image_url 列
-- 库：springboot_test  执行日期参考：2026-11-02
-- 说明：幂等脚本，列已存在则跳过，可重复执行；
--       已有数据 image_url 为 NULL，前端自动回退显示 emoji 图标
-- 用法（任选其一）：
--   Navicat 打开 springboot_test 库 → 运行 SQL 文件 → 选本文件
--   或命令行："C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -uroot -p123456 < 本文件
-- ============================================================

USE springboot_test;
SET NAMES utf8mb4;

-- 存储过程：列不存在时才 ALTER（MySQL 8 不支持 ADD COLUMN IF NOT EXISTS）
DELIMITER $$
DROP PROCEDURE IF EXISTS jjk_add_image_url $$
CREATE PROCEDURE jjk_add_image_url(IN tbl VARCHAR(64))
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = tbl AND COLUMN_NAME = 'image_url'
  ) THEN
    SET @sql = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN image_url VARCHAR(255) DEFAULT NULL');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END IF;
END $$
DELIMITER ;

CALL jjk_add_image_url('jjk_character');
CALL jjk_add_image_url('jjk_tool');
CALL jjk_add_image_url('jjk_event');

DROP PROCEDURE IF EXISTS jjk_add_image_url;

-- 验证：应看到三张表都有 image_url 列
-- SELECT TABLE_NAME, COLUMN_NAME FROM information_schema.COLUMNS
-- WHERE TABLE_SCHEMA = 'springboot_test' AND COLUMN_NAME = 'image_url';
