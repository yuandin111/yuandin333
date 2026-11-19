-- =============================================================
-- P0 修复：单独补建好友/私信三张表（安全脚本）
-- 来源：springBootTest/sql/forum_friends_init.sql 中 friend_* 片段
-- 只 DROP/CREATE friend_* 三张表并写种子数据，绝不触碰 forum_* / sys_user / jjk_*
-- 执行：mysql -uroot -p123456 --default-character-set=utf8mb4 -D springboot_test < 修复好友表_20261119.sql
-- =============================================================
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `friend_message`;
DROP TABLE IF EXISTS `friendship`;
DROP TABLE IF EXISTS `friend_request`;

CREATE TABLE `friend_request` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `from_user_id` bigint NOT NULL COMMENT '发起人',
  `from_user_name` varchar(50) NOT NULL,
  `to_user_id` bigint NOT NULL COMMENT '接收人',
  `to_user_name` varchar(50) NOT NULL,
  `message` varchar(200) DEFAULT NULL COMMENT '验证消息',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '0待处理 1已同意 2已拒绝',
  `create_time` datetime DEFAULT NULL,
  `handle_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_to` (`to_user_id`,`status`),
  KEY `idx_from` (`from_user_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='好友申请';

CREATE TABLE `friendship` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `friend_id` bigint NOT NULL,
  `friend_name` varchar(50) NOT NULL,
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_friend` (`user_id`,`friend_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='好友关系';

CREATE TABLE `friend_message` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `from_user_id` bigint NOT NULL,
  `to_user_id` bigint NOT NULL,
  `content` varchar(1000) NOT NULL,
  `is_read` tinyint NOT NULL DEFAULT 0 COMMENT '0未读 1已读',
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_pair` (`from_user_id`,`to_user_id`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='好友私信';

-- ---------------------------- 好友关系（双向各一条） ----------------------------
INSERT INTO `friendship` (`user_id`,`friend_id`,`friend_name`,`create_time`) VALUES
 (1,2,'虎杖悠仁','2026-11-12 09:05:00'),(2,1,'admin','2026-11-12 09:05:00'),
 (1,3,'伏黑惠','2026-11-12 09:06:00'),(3,1,'admin','2026-11-12 09:06:00'),
 (1,4,'钉崎野蔷薇','2026-11-12 09:07:00'),(4,1,'admin','2026-11-12 09:07:00'),
 (1,5,'五条悟','2026-11-12 09:08:00'),(5,1,'admin','2026-11-12 09:08:00'),
 (2,3,'伏黑惠','2026-11-12 09:09:00'),(3,2,'虎杖悠仁','2026-11-12 09:09:00'),
 (4,5,'五条悟','2026-11-12 09:10:00'),(5,4,'钉崎野蔷薇','2026-11-12 09:10:00');

INSERT INTO `friend_request` (`id`,`from_user_id`,`from_user_name`,`to_user_id`,`to_user_name`,`message`,`status`,`create_time`,`handle_time`) VALUES
 (1,7,'狗卷棘',1,'admin','鲑鱼！想加个好友一起整理饭团语词典。',0,'2026-11-12 11:00:00',NULL),
 (2,6,'七海建人',1,'admin','看到考据区那篇，想聊聊束缚分类。',0,'2026-11-12 11:20:00',NULL),
 (3,1,'admin',9,'乙骨忧太','色纸企划很好看，交个好友吧！',0,'2026-11-12 11:40:00',NULL),
 (4,8,'禅院真希',2,'虎杖悠仁','同人图区互换色纸吗？',1,'2026-11-12 08:30:00','2026-11-12 08:40:00');

INSERT INTO `friend_message` (`id`,`from_user_id`,`to_user_id`,`content`,`is_read`,`create_time`) VALUES
 (1,2,1,'管理员老师，索引贴我把便利店那篇自荐上去了～',1,'2026-11-12 09:16:00'),
 (2,1,2,'看到啦，写得很稳，已经加进精华候选。',1,'2026-11-12 09:17:00'),
 (3,2,1,'谢谢！连载区那边我也想开个坑，回头发你看看。',1,'2026-11-12 09:19:00'),
 (4,5,1,'放学后的便利店，我投一票年度最佳。',1,'2026-11-12 10:00:00'),
 (5,1,5,'最强老师也看同人区啊。',1,'2026-11-12 10:01:00'),
 (6,5,1,'当然，毕竟是学生写的。',0,'2026-11-12 10:02:00');

SET FOREIGN_KEY_CHECKS = 1;

-- 校验
SELECT 'friend_request' t, COUNT(*) n FROM friend_request
UNION ALL SELECT 'friendship', COUNT(*) FROM friendship
UNION ALL SELECT 'friend_message', COUNT(*) FROM friend_message;
