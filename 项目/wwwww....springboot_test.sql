/*
 Navicat Premium Dump SQL

 Source Server         : test
 Source Server Type    : MySQL
 Source Server Version : 80039 (8.0.39)
 Source Host           : localhost:3306
 Source Schema         : springboot_test

 Target Server Type    : MySQL
 Target Server Version : 80039 (8.0.39)
 File Encoding         : 65001

 Date: 16/11/2026 09:41:16
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for forum_comment
-- ----------------------------
DROP TABLE IF EXISTS `forum_comment`;
CREATE TABLE `forum_comment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `post_id` bigint NOT NULL COMMENT '帖子ID',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '被回复的评论ID，NULL 表示楼层主评',
  `reply_to_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '被回复者用户名',
  `user_id` bigint NOT NULL COMMENT '评论者ID',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '评论者用户名',
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '评论内容',
  `like_count` int NOT NULL DEFAULT 0,
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1正常 0已删除',
  `create_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_post`(`post_id` ASC) USING BTREE,
  INDEX `idx_parent`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '论坛评论与回复' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of forum_comment
-- ----------------------------
INSERT INTO `forum_comment` VALUES (1, 25, NULL, NULL, 1, 'admin', '111', 0, 0, '2026-11-16 09:36:53');

-- ----------------------------
-- Table structure for forum_like
-- ----------------------------
DROP TABLE IF EXISTS `forum_like`;
CREATE TABLE `forum_like`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `post_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_post_user`(`post_id` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '帖子点赞（一人一帖一次）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of forum_like
-- ----------------------------

-- ----------------------------
-- Table structure for forum_post
-- ----------------------------
DROP TABLE IF EXISTS `forum_post`;
CREATE TABLE `forum_post`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '帖子ID',
  `title` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '正文',
  `category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'fanwork' COMMENT '板块：fanwork同人二创/fanart同人图绘/discuss剧情讨论/lore术式考据/chat闲聊水区',
  `tags` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标签，英文逗号分隔',
  `cover_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '封面图URL（可空，前端回退渐变卡片）',
  `author_id` bigint NOT NULL COMMENT '作者用户ID',
  `author_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '作者用户名（冗余，避免列表联表）',
  `like_count` int NOT NULL DEFAULT 0 COMMENT '点赞数',
  `comment_count` int NOT NULL DEFAULT 0 COMMENT '评论数',
  `view_count` int NOT NULL DEFAULT 0 COMMENT '浏览量',
  `is_top` tinyint NOT NULL DEFAULT 0 COMMENT '是否置顶',
  `is_essence` tinyint NOT NULL DEFAULT 0 COMMENT '是否精华',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1正常 0已删除',
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  INDEX `idx_author`(`author_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '论坛帖子' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of forum_post
-- ----------------------------
INSERT INTO `forum_post` VALUES (1, '【剧情】重看涩谷事变：那场雨其实早就埋下了', '最近重新翻涩谷篇，发现一个很细的铺垫：事变正式开始前，几乎每一场戏的湿度都在升高。地铁站墙面的水渍、角色对话里提到的「今晚好闷」，再到五条被封印前那场不大不小的雨。\n\n作者很喜欢用天气做倒计时。降雨本身不是渲染气氛，而是在暗示「帐」落下之前，整个涩谷的水汽浓度已经被咒力改变过——普通人只觉得闷，术师应该会有一点隐隐的不适，但谁都没来得及细想。\n\n如果从这个角度回看，五条悟走进站台前抬头看天那一格，可能不是闲笔。他大概率察觉到了，只是他不认为那能拦住他。\n\n大家觉得这种「环境先于事件」的写法，在后面的篇章里还有复现吗？', 'discuss', '剧情,涩谷事变,细节,伏笔', NULL, 1, 'admin', 0, 0, 0, 0, 1, 1, '2026-11-13 20:10:00', '2026-11-13 20:10:00');
INSERT INTO `forum_post` VALUES (2, '【剧情】死灭回游的规则设计，其实是整场大型「束缚」', '死灭回游常被吐槽规则复杂，但换个角度看，它本身就是羂索设下的一个超大型束缚：\n\n· 玩家必须宣誓参加——对应束缚的「契约成立」；\n· 点数可以转让——给「交换」留了口子；\n· 追加规则由管理者公布——束缚条件可以事后补充，这正是全篇反复强调的「束缚不对等」。\n\n最有意思的是，主角团通关的方式不是正面打破规则，而是利用规则之间的时间差追加新条款。也就是说他们赢的方式和羂索设局的方式是同一种：都在给束缚加条款。\n\n这么看「规则战」篇真正的主题不是智斗，而是——谁更懂束缚，谁就更接近这个世界的底层语法。', 'discuss', '死灭回游,规则,束缚,分析', NULL, 3, '伏黑惠', 0, 0, 0, 0, 0, 1, '2026-11-13 21:05:00', '2026-11-13 21:05:00');
INSERT INTO `forum_post` VALUES (3, '【剧情】怀玉篇为什么是整部作品的「轴」', '很多人把怀玉篇当前传看，但我觉得它更像整部作品的轴心：后面几乎所有冲突，都能在怀玉找到原型。\n\n五条和夏油的分歧不是「善恶」分歧，而是同一个问题的两种答案——力量应该为谁服务。五条给出的答案是「守护眼前的具体的人」，夏油的答案是「为了理念可以牺牲具体的人」。\n\n注意，后续剧情里几乎所有主要角色都被迫在这两个答案之间站队：七海选了前者后离开又回来，伏黑被问到「你想救谁」，虎杖的「正确的死」其实也是这道题的变体。\n\n所以怀玉不是回忆杀，是考题。后面每一章都是答卷。', 'discuss', '怀玉篇,五条,夏油,主题', NULL, 5, '五条悟', 0, 0, 0, 0, 1, 1, '2026-11-14 10:30:00', '2026-11-14 10:30:00');
INSERT INTO `forum_post` VALUES (4, '【讨论】「正确的死」这个命题，虎杖答到哪里了', '爷爷留下的那句话贯穿全篇，但虎杖对它的理解一直在变：\n\n初期：「不想让更多人死掉」——把死当成要避免的结果；\n中期（顺平事件后）：开始意识到有些死无法阻止，只能决定「自己站在哪一边」；\n涩谷之后：目睹大规模死亡后，他的答案从「阻止死」变成了「背负着走下去」。\n\n有意思的是，这个命题从来不是他自己想通的，而是一次次被现实改写的。这可能就是这个角色最特别的地方——他的成长不是变强，是答案被反复打碎又重建。\n\n大家觉得到现在，他的答案定型了吗？还是说最终章会再给一次改写？', 'discuss', '虎杖,正确的死,剧情,分析', NULL, 2, '虎杖悠仁', 0, 0, 0, 0, 0, 1, '2026-11-14 14:20:00', '2026-11-14 14:20:00');
INSERT INTO `forum_post` VALUES (5, '【讨论】乙骨回归那段戏，为什么安排在那个时候', '从叙事节奏看，乙骨在涩谷之后、死灭回游之前回归，时机非常讲究。\n\n如果早回来，涩谷的绝望感会打折；晚回来，主角团又没有能在回游里撑住场面的顶级战力。作者把他放在「秩序刚崩塌、新规则刚建立」的缝隙里，让他同时承担两件事：对内稳定军心，对外展示「高专侧依然有底牌」。\n\n而且他回来之后做的第一件事不是战斗，是处理内部事务——这其实是在替五条补位。老师不在，总要有人把「最强在场」的那种安全感补回来，哪怕只是形式上的。\n\n这段安排你打几分？', 'discuss', '乙骨,剧情结构,节奏', NULL, 9, '乙骨忧太', 0, 0, 0, 0, 0, 1, '2026-11-14 19:40:00', '2026-11-14 19:40:00');
INSERT INTO `forum_post` VALUES (6, '【人物成长】伏黑惠：从「不平等的救人」到学会被救', '伏黑的成长线有个很隐蔽的转向。\n\n早期的他救人是有条件的：只救自己认可的人，先在心里算一遍值不值得。这不是冷漠，是他给自己上的保险——只要先做了减法，失去的时候就不会太疼。\n\n转折发生在两个时刻：一是虎杖说「你救过我，所以这次换我」；二是姐姐的事让他第一次承认「我也有想被救的时候」。\n\n从「我来决定救谁」到「我也允许自己被救」，这是比任何新术式都大的升级。影法术的边界在拓宽，人的边界也是。', 'discuss', '人物成长,伏黑,成长线', NULL, 3, '伏黑惠', 0, 0, 0, 0, 1, 1, '2026-11-14 21:15:00', '2026-11-14 21:15:00');
INSERT INTO `forum_post` VALUES (7, '【人物成长】钉崎野蔷薇：她的坚强不需要「被治愈」', '想反驳一种常见读法：把钉崎解读成「用强势掩盖乡下来的自卑」。\n\n重看她的戏份会发现，她从来没有自卑过。她记得很清楚自己为什么来东京——不是逃离，是奔赴。她对故乡没有怨，对城市没有怯，她是少有的「出厂设置就完整」的角色。\n\n所以她的成长线不是「变强」也不是「被治愈」，而是「在一个不断夺走东西的世界里，练习怎么不弄丢自己」。她的锤子从来砸向别人，因为她自己心里没有裂缝要补。\n\n这样的角色在少年漫里太少了，且行且珍惜。', 'discuss', '人物成长,钉崎,角色分析', NULL, 4, '钉崎野蔷薇', 0, 0, 0, 0, 0, 1, '2026-11-15 09:30:00', '2026-11-15 09:30:00');
INSERT INTO `forum_post` VALUES (8, '【人物成长】禅院真希：毁掉家族之前，先毁掉家族给的自己', '真希的成长线是全篇最决绝的一条。\n\n别人是在既有道路上变强，她是先把路拆了。禅院家给她的定义是「没有咒力的残次品」，她的回应不是证明「我也能有咒力」，而是把这个评价体系整个掀翻——你们用咒力丈量人，那我就让你们看看没有咒力的人能走到哪里。\n\n真依的死是这条线最狠的一笔：双胞胎里必须消失一个，另一个才能完整。这个设定残忍，但它让真希的「天与咒缚」从缺陷变成了她亲手选择的完整。\n\n成长线的天花板，大概就是把「被定义」改写成「自定义」。', 'discuss', '人物成长,真希,禅院家,天与咒缚', NULL, 8, '禅院真希', 0, 0, 0, 0, 0, 1, '2026-11-15 11:00:00', '2026-11-15 11:00:00');
INSERT INTO `forum_post` VALUES (9, '【人物成长】七海建人：一个成年人的两次辞职', '七海的成长线很短但很完整，完整到可以用「两次辞职」概括。\n\n第一次，他辞掉咒术师去做普通人——理由是「咒术师是狗屎」。这不是逃避，是一个看清代价的人做出的理性选择。\n\n第二次，他辞掉普通人的生活回来——理由变成了「劳动是狗屎，但有些事只有我能做」。注意这个变化：他回来时不再期待这份职业变好，只是接受了自己属于这里。\n\n成年人的成长往往不是变得热血，而是停止假装自己还有别的选择。他最后赴死时那句遗言之所以有分量，是因为那是两次辞职之后剩下的、完全自愿的部分。', 'discuss', '人物成长,七海,成年人,角色分析', NULL, 6, '七海建人', 0, 0, 0, 0, 1, 1, '2026-11-15 15:20:00', '2026-11-15 15:20:00');
INSERT INTO `forum_post` VALUES (10, '【人物成长】五条悟：最强的人，成长线藏在「放手」里', '五条悟有成长线吗？表面上没有，他出场即巅峰。\n\n但细看怀玉到正篇，他其实变了。怀玉时期他说「我们是最强的」，用的是复数；星浆体事件之后，他开始独自承担「最强」这个称号，也独自承担它带来的孤独。\n\n他的成长是学会一件事：最强救不了所有人。于是他从「我来解决一切」慢慢转向「我来培养能解决一切的人」。当老师，就是他给自己找到的、不用独自站在顶端的方式。\n\n所以狱门疆里那段戏才成立——他最放心不下的不是世界，是教室。', 'discuss', '人物成长,五条,怀玉,教师', NULL, 5, '五条悟', 0, 0, 0, 0, 0, 1, '2026-11-15 18:45:00', '2026-11-15 18:45:00');
INSERT INTO `forum_post` VALUES (11, '【考据】咒具分级考：从「游云」说起，特级咒具到底特在哪', '咒具分级的官方描述很简略，综合原作信息整理一下我的理解：\n\n咒具的核心价值在于「不依赖术式也能输出咒力效果」，所以它天然适合两种人：咒力少的（如真希早期），和术式不适合近战的。\n\n以「游云」为例，它作为特级咒具，「特」不在锋利，而在它本身就是一段固化的术式——使用者的咒力只是点火，刀身里封存的才是弹药。这和普通咒具「注入多少出多少」是质变区别。\n\n推论：特级咒具的制作大概率需要术师长期以同一术式浸染器物，某种意义上，每件特级咒具都是一位无名术师的「领域残骸」。欢迎补充反例。', 'lore', '咒具,游云,考据,分级', NULL, 1, 'admin', 0, 0, 0, 0, 1, 1, '2026-11-15 20:00:00', '2026-11-15 20:00:00');
INSERT INTO `forum_post` VALUES (12, '【考据】天逆鉾与黑绳：「使术式无效化」的两种实现路径', '这两件咒具经常被放在一起讨论，因为它们的效果表面相同——让术式失效。但机制应该不一样：\n\n天逆鉾：强制解除「发动中」的术式，关键词是「解除」。它针对的是术式的结果状态，所以能破无下限这种常驻型防御。\n\n黑绳：干扰「术式的成立条件」，关键词是「扰乱」。它更像在咒力传导的链路上打结，让术式还没成型就散掉。\n\n一个是对付「结果」，一个是对付「过程」。这也解释了为什么两者在面对不同类型的术式时表现差异很大。\n\n顺带一提，这类「对抗系咒具」的存在本身，说明咒具制作技术里有一套独立于术式体系的知识树，这条线原作挖得还不够。', 'lore', '咒具,天逆鉾,黑绳,术式', NULL, 3, '伏黑惠', 0, 0, 0, 0, 0, 1, '2026-11-16 08:40:00', '2026-11-16 08:40:00');
INSERT INTO `forum_post` VALUES (13, '【考据】真希的武器轮换，藏着她的成长刻度', '统计一下真希用过的武器：长枪、三节棍、日本刀，再到后来那柄意义特殊的刀。\n\n武器更换不是随机换装，每一把都对应她能力结构的跃迁：\n· 长枪：弥补射程与力量，是她「还不够强」时的选择；\n· 三节棍：开始利用天与咒缚的机动性，打法从「对抗」转向「缠绕」；\n· 日本刀：完整的她选择了最朴素的武器——不再需要武器补完自己，刀只是手臂的延长。\n\n咒具是术师的外置器官。当一个人不再频繁更换器官，说明她长成了。', 'lore', '咒具,真希,武器,天与咒缚', NULL, 8, '禅院真希', 0, 0, 0, 0, 0, 1, '2026-11-16 09:10:00', '2026-11-16 09:10:00');
INSERT INTO `forum_post` VALUES (14, '【考据】为什么钉崎的锤子不算咒具？论「媒介」与「咒具」的边界', '一个容易混淆的点：钉崎的锤子、钉子、稻草人，严格来说都不算咒具，只是「媒介」。\n\n区别在于咒力的流向：\n· 咒具：咒力储存在器物里，器物本身产生效果；\n· 媒介：咒力经由器物传导，效果发生在别处。\n\n她的共鸣伤害落在目标身上，锤子全程只是「基站」。所以她的装备可以随便换——便利店的钉子也能用——因为重要的是术式，不是装备。\n\n但反过来，如果她把同一柄锤子用到老，日积月累浸染下来，它未必不会「咒具化」。器物陪术师走久了，是会沾上主人的形状的。这个猜想我在「共鸣与咒具边界」那篇里展开过，欢迎考古。', 'lore', '咒具,共鸣,钉崎,媒介,设定', NULL, 4, '钉崎野蔷薇', 0, 0, 1, 0, 0, 1, '2026-11-16 09:40:00', '2026-11-16 09:40:00');
INSERT INTO `forum_post` VALUES (15, '【同人】一年级的值日表', '高专的值日表贴在走廊公告栏第三格，玻璃有点裂，没人修。\n\n周一：虎杖。他扫地很快，但总会把簸箕里的灰倒在同一个花坛，被伏黑发现过一次，理由是「那朵花看起来比较饿」。\n\n周二：伏黑。他擦黑板只用湿抹布，干的不碰。钉崎问为什么，他说粉笔灰会让玉犬打喷嚏。钉崎说玉犬是影子不会打喷嚏。伏黑说：「你听过吗？」钉崎沉默了。\n\n周三：钉崎。她的值日风格是大扫除式的，窗台、门框、公告栏的玻璃全擦一遍，顺便把裂了的事报修。第四周玻璃真的换了新的。\n\n公告栏最下面有一行褪色的字，据说是上一届留下的：「把走廊扫干净的人，运气不会太差。」\n\n没人擦掉它。', 'fanwork', '同人,日常,一年级,治愈', NULL, 2, '虎杖悠仁', 0, 0, 0, 0, 1, 1, '2026-11-15 12:30:00', '2026-11-15 12:30:00');
INSERT INTO `forum_post` VALUES (16, '【同人·短篇】七海先生的一周（周五限定）', '周五的七海建人，是七种七海里最松弛的一种。\n\n五点下班。五点零七分，他已经坐在常去的面包房靠窗位置，面前是一只法棍和一杯黑咖啡。店员认识他，从不多话，只会在下雨天把靠窗的座位提前擦干净。\n\n这一小时不谈工作，不想咒灵，不看手机。他曾经计算过：一周有一百六十八小时，真正属于自己的清醒时间，大概只有这五十六分钟。\n\n「七三开。」他对自己说。三分给世界，七分……七分里有六分半也被世界拿走了，剩下这半小时，谁都不给。\n\n后来那个背书包的学生又在周五出现过一次，坐在隔壁桌。七海把法棍掰了一半推过去。\n\n「吃吗。」\n「……谢谢。」\n\n周五的法棍，两个人分，也还是完整的。', 'fanwork', '同人,七海,短篇,周五,治愈', NULL, 6, '七海建人', 0, 0, 0, 0, 0, 1, '2026-11-15 17:00:00', '2026-11-15 17:00:00');
INSERT INTO `forum_post` VALUES (17, '【同人】狗卷棘的年末扫除', '年末大扫除，狗卷负责整理器材室。\n\n熊猫半小时后探头进来，发现器材室安静得反常。狗卷跪坐在货架前，手里捏着一张去年的借物登记表，盯着「饭团（一个）」那栏出神。\n\n「鲑鱼。」他说。意思是：这条是我写的，但我忘了借给谁了。\n\n熊猫帮他回忆：「好像是虎杖，运动会那天。」\n\n「明太子。」意思是：那他为什么不还。\n\n「可能吃了。」\n\n「……金枪鱼。」意思是：算了，当我请的。\n\n扫除结束时，器材室干净得能照出人影。狗卷在登记表最后一页补了一行新规定：「饭团类借出概不追讨。」\n\n熊猫说这条规定很有温度。狗卷点了点头，把登记表放回架子最高层——\n\n鲑鱼。', 'fanwork', '同人,狗卷,熊猫,轻松,年末', NULL, 7, '狗卷棘', 0, 0, 0, 0, 0, 1, '2026-11-15 21:30:00', '2026-11-15 21:30:00');
INSERT INTO `forum_post` VALUES (18, '【同人】如果里香也能吃到便当（乙骨视角）', '乙骨做便当总是做多一人份。\n\n同年级的人笑他食量大，他不解释。多的那一份用旧便当盒装着，深蓝色，边角磨白了，是很多年前用过的那种款式。\n\n午休时他会把它摆在对面座位，摆好筷子，然后开始吃自己那份。吃到一半，他会停下来，把对面盒里的玉子烧翻个面——「你以前总说不爱吃边上焦的部分」。\n\n没有人回答。窗外的风把窗帘吹起来，又落下去，轻轻搭在那个深蓝色的盒子上，像谁伸手按住了它。\n\n乙骨低头继续吃饭，耳朵有点红。\n\n「……咸了吗？下次少放点盐。」', 'fanwork', '同人,乙骨,里香,便当,微刀', NULL, 9, '乙骨忧太', 0, 0, 0, 0, 1, 1, '2026-11-16 08:00:00', '2026-11-16 08:00:00');
INSERT INTO `forum_post` VALUES (19, '【连载预告】高专的雨天（二）：影子里的回信', '上回说到那锅来历不明的汤。\n\n这一节的关键词是「回信」。伏黑在伞架最里面发现了一把不属于任何人的旧伞，伞柄里塞着一张折得很小的纸条，上面的字迹被潮气泡得发毛，只能认出半句：\n\n「……影子里的话，要等到放晴……」\n\n玉犬从那天起变得很奇怪，总在玄关趴着，像等什么。鵺倒是比平时安静。\n\n第二节这周内更新。先剧透一个无关紧要的细节：那锅汤最后被喝完了，喝的人是没想到的人。', 'fanwork', '连载预告,高专,雨天,伏黑', NULL, 3, '伏黑惠', 0, 0, 1, 0, 0, 1, '2026-11-16 09:20:00', '2026-11-16 09:20:00');
INSERT INTO `forum_post` VALUES (20, '【同人图】雨中的玉犬 · 水彩练习', '一张水彩练习，画的是雨天玄关的玉犬。\n\n构图想了很久，最后决定只画两只犬的背影和一大片留白的地砖，雨声全靠颜色的「湿」来表现——颜料没干就叠第二层，让边缘自己晕开，晕成什么样算什么样。\n\n翻车三次之后发现：水彩这东西和影子一样，你越想控制它，它越不听。第四次我放弃控制，反而成了。\n\n纸是三百克中纹，颜料就是最普通的学院级。扫描版放图包了，做壁纸自取，转载请署名。', 'fanart', '同人图,水彩,玉犬,原创', NULL, 10, '熊猫', 0, 0, 0, 0, 0, 1, '2026-11-15 14:10:00', '2026-11-15 14:10:00');
INSERT INTO `forum_post` VALUES (21, '【同人图】「领域展开」系列第二张：用负空间画压迫感', '接着上次的线稿思路，这次挑战上色版。\n\n核心手法就一个字：省。人物不上色，只给轮廓光；领域内部全部压成深色，只留一道从人物背后透出来的亮边。压迫感不来自「画了多少」，而来自「空了多少」。\n\n有个小心得：画领域这种看不见边界的东西，最好的参照物是潜水照片——那种光线被介质吃掉的感觉，和领域里的氛围是通的。\n\n系列一共四张，下一张想画「领域从内部被打破」的瞬间，已经在起稿了。', 'fanart', '同人图,领域展开,上色,过程', NULL, 8, '禅院真希', 0, 0, 0, 0, 0, 1, '2026-11-15 19:20:00', '2026-11-15 19:20:00');
INSERT INTO `forum_post` VALUES (22, '【同人图】高专食堂群像 · 四格漫试作', '试着画了组四格：食堂中午十二点的四个人。\n\n第一格：虎杖端着堆成小山的餐盘找座位；\n第二格：伏黑的餐盘永远荤素三七开，座位永远靠窗；\n第三格：钉崎在跟打饭阿姨交涉多一勺咖喱；\n第四格：三个人的筷子同时伸向最后一块炸鸡。\n\n没有对白，因为真正的同学吃饭不需要说话。\n\n画风是简笔，上色用的马克笔扫描。如果喜欢这种日常向，下次画二年级组（熊猫已经预定要占两格）。', 'fanart', '同人图,四格,食堂,日常', NULL, 4, '钉崎野蔷薇', 0, 0, 0, 0, 0, 1, '2026-11-16 08:30:00', '2026-11-16 08:30:00');
INSERT INTO `forum_post` VALUES (23, '【水楼】一人说一个你心目中的「最佳路人镜头」', '不聊主角，聊聊那些只出现一格但忘不掉的路人：\n\n我先来：涩谷事变里有个镜头，避难的人群里有个大叔把自己的外套披在陌生小孩身上，全程没有台词，下一格就被人群冲散了。就这一格，我把那一话反复看了三遍。\n\n灾难场景里最打动人的从来不是术式对轰，是普通人的下意识。\n\n楼下的跟上，规则：只能说一格，说多了算犯规。', 'chat', '水楼,路人,细节控', NULL, 2, '虎杖悠仁', 0, 0, 0, 0, 0, 1, '2026-11-15 22:40:00', '2026-11-15 22:40:00');
INSERT INTO `forum_post` VALUES (24, '【水楼】如果高专有社团，你最想进哪个', '课间脑洞：假设没有咒灵，高专就是个普通学校——\n\n· 虎杖铁定田径部，而且会被所有部门借人；\n· 伏黑大概是生物部或者图书委员，表面嫌弃实际全勤；\n· 钉崎必须是手工部+购物研究会同好会双挂；\n· 狗卷……料理部。这个不需要解释。\n\n我先报名伏黑的生物部，就想看看他养玉犬的观察日记会写成什么样。\n\n你们呢？', 'chat', '水楼,脑洞,社团,日常', NULL, 7, '狗卷棘', 0, 0, 0, 0, 0, 1, '2026-11-16 09:00:00', '2026-11-16 09:00:00');
INSERT INTO `forum_post` VALUES (25, '111', '111', 'fanwork', '11', NULL, 1, 'admin', 0, 0, 1, 0, 0, 1, '2026-11-16 09:13:52', '2026-11-16 09:13:52');

-- ----------------------------
-- Table structure for jjk_character
-- ----------------------------
DROP TABLE IF EXISTS `jjk_character`;
CREATE TABLE `jjk_character`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '人物名',
  `icon` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '图标emoji',
  `role` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '身份/称号',
  `camp` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'school' COMMENT '阵营：school高专 / curse咒灵·诅咒师',
  `ability` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '术式/能力',
  `tags` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '关键词，英文逗号分隔',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '详细介绍',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '配图URL，无图前端回退emoji',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序，越小越靠前',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '人物志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of jjk_character
-- ----------------------------
INSERT INTO `jjk_character` VALUES (1, '虎杖悠仁', '👊', '东京校一年级', 'school', '超人体质 · 宿傩容器', '主角,容器', '为完成爷爷“帮助他人”的遗愿，吞下特级咒物“宿傩手指”的少年。身体能力与咒力总量远超常人，性格直率善良，越是绝境越会为他人挥拳。', NULL, 1, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (2, '伏黑惠', '🐕', '东京校一年级', 'school', '十种影法术', '式神', '禅院家分家出身的冷静战术派，以式神（玉犬、鵺、大蛇等）布阵取胜。嘴上说着功利，行动却始终站在保护同伴的那一侧。', NULL, 2, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (3, '钉崎野蔷薇', '🔨', '东京校一年级', 'school', '共鸣', '锤与钉', '从乡村来到东京的自信少女，以钉子与锤子为武器。讨厌被轻视，战斗直觉与意志力都极其出色，飒爽又鲜活。', NULL, 3, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (4, '五条悟', '😎', '特级咒术师 · 教师', 'school', '无下限术式 · 领域「无量空处」', '现代最强,六眼', '现代最强咒术师，天生“六眼”持有者。护短、爱胡闹、实力深不可测；涩谷事变中被羂索以狱门疆封印，成为整个局势的转折点。', NULL, 4, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (5, '七海建人', '☕', '一级咒术师', 'school', '十划经', '社畜,七三', '厌恶加班的前金融精英，习惯以“七三”比例分析目标弱点。沉稳可靠的职场前辈，涩谷事变中战死于真人之手。', NULL, 5, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (6, '家入硝子', '💊', '东京校校医', 'school', '反转术式', '治疗', '高专最强的“医生”，以反转术式治愈咒术造成的伤口。毒舌又可靠，是学生们最后的保险。', NULL, 6, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (7, '乙骨忧太', '🗡️', '特级咒术师', 'school', '复制 · 里香', '前传主角', '前传主角，与过咒怨灵“里香”立下婚约的特级术师，能复制他人术式。涩谷之后担任虎杖的“处刑人”，实则与五条一系并肩。', NULL, 7, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (8, '夏油杰', '🌑', '前特级咒术师', 'curse', '咒灵操术', '挚友', '五条悟的昔日挚友，因理念相悖叛离高专，发动“百鬼夜行”。死后躯体被羂索夺取，沦为阴谋的皮囊。', NULL, 8, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (9, '东堂葵', '💪', '京都校三年级', 'school', '不义游戏', '体操', '前体操选手，热血耿直的前辈，信奉“交到一百个朋友”。拍手即可交换物体位置，涩谷中为救虎杖付出一臂。', NULL, 9, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (10, '禅院真希', '⚔️', '东京校二年级', 'school', '天与咒缚', '体术', '禅院家分家出身，以零咒力换取超凡体能的剑士。后突破束缚成为完全体，挥舞特级咒具“游云”大闹禅院家。', NULL, 10, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (11, '狗卷棘', '🍙', '东京校二年级', 'school', '咒言', '语言', '语言即咒术的术师，平时用饭团配料示意咒言效果。沉默寡言，却总在关键时刻挡在同伴身前。', NULL, 11, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (12, '熊猫', '🐼', '东京校二年级', 'school', '咒骸', '夜蛾造物', '夜蛾校长制造的自主思考咒骸，大哥型角色。肉体强悍、核心众多，是队伍里可靠的重型战力。', NULL, 12, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (13, '伏黑甚尔', '🔪', '术师杀手', 'curse', '天与咒缚 · 咒具运用', '惠之父', '伏黑惠之父，零咒力的传说暗杀者。咒具运用出神入化，曾以天逆鉾重创五条悟，并成功刺杀星浆体天内理子。', NULL, 13, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (14, '真人', '🎭', '特级咒灵', 'curse', '无为转变', '改造灵魂', '由人类对自身的诅咒诞生的咒灵，能改造灵魂、重塑肉体。视人命为玩具，涩谷事变的核心凶手之一。', NULL, 14, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (15, '两面宿傩', '👹', '诅咒之王', 'curse', '解 · 捌 · 领域「伏魔御厨子」', '千年最强', '千年前的最强术师，死后化为二十根特级咒物手指。寄宿于虎杖体内，冷静、残酷、唯我独尊，等待复活之日。', NULL, 15, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_character` VALUES (16, '羂索', '🧠', '千年术师', 'curse', '咒灵操术 · 夺舍', '幕后黑手', '不断更换身体的千年阴谋家，现占据夏油杰的躯体。以“死灭回游”收集咒力，编织波及全日本的巨大漩涡。', NULL, 16, '2026-11-09 08:58:17', '2026-11-09 08:58:17');

-- ----------------------------
-- Table structure for jjk_event
-- ----------------------------
DROP TABLE IF EXISTS `jjk_event`;
CREATE TABLE `jjk_event`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `era` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '时代/时间',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '事件标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '详细介绍',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '配图URL，无图前端回退emoji',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序，越小越靠前',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '重要事件时间线' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of jjk_event
-- ----------------------------
INSERT INTO `jjk_event` VALUES (1, '约千年以前', '咒术全盛时代 · 宿傩之死', '诅咒之王两面宿傩横行于世，死后化为二十根手指散落千年，成为咒术界最高机密——特级咒物。', NULL, 1, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_event` VALUES (2, '怀玉 · 玉折', '星浆体暗杀与挚友分岐', '五条悟与夏油杰的高专时代。术师杀手伏黑甚尔刺杀星浆体天内理子后被五条击毙；理念相悖的二人，自此走向不同的道路。', NULL, 2, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_event` VALUES (3, '前传 · 0卷', '百鬼夜行', '夏油杰发动“百鬼夜行”，欲消灭所有非术师。转学生乙骨忧太与里香挺身而出将其阻止，里香得以成佛。', NULL, 3, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_event` VALUES (4, '2018年', '宿傩容器诞生', '虎杖悠仁为救同学吞下宿傩手指，成为“容器”进入东京咒术高专，并在少年院事件中首次与宿傩直面。', NULL, 4, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_event` VALUES (5, '2018年', '交流会与牺牲', '京都姊妹校交流会明争暗斗；吉野顺平被真人诱入歧途；花御来袭，究极机械丸战死——少年们付出成长的代价。', NULL, 5, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_event` VALUES (6, '2018 · 10月31日', '渋谷事变', '万圣节之夜，涩谷被“帐”覆盖。五条悟遭狱门疆封印，七海建人战死，钉崎野蔷薇濒死，东堂断臂——咒术界根基动摇。', NULL, 6, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_event` VALUES (7, '2018 · 11月', '死灭回游开幕', '羂索启动全国结界猎杀游戏，津美纪被卷入其中。禅院家灭门、真希突破天与咒缚；高专众人为救人兼寻解封之法参战。', NULL, 7, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_event` VALUES (8, '终局', '新宿决战', '“天使”解开狱门疆，五条悟回归，与占据伏黑惠身体的宿傩展开跨时代决战并战死。虎杖以灵魂一击驱散诅咒之王，以人与人的联结收场。', NULL, 8, '2026-11-09 08:58:17', '2026-11-09 08:58:17');

-- ----------------------------
-- Table structure for jjk_tool
-- ----------------------------
DROP TABLE IF EXISTS `jjk_tool`;
CREATE TABLE `jjk_tool`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '咒具名',
  `icon` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '图标emoji',
  `grade` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '等级文字，如：特级咒具',
  `grade_class` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'unknown' COMMENT '等级样式：top/relic/maybe/unknown',
  `owner` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '持有者',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '详细介绍',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '配图URL，无图前端回退emoji',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序，越小越靠前',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '咒具图鉴' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of jjk_tool
-- ----------------------------
INSERT INTO `jjk_tool` VALUES (1, '天逆鉾', '🗡️', '特级咒具', 'top', '伏黑甚尔 → 被五条悟没收封印', '十手状胁差，可强制解除发动中的术式，堪称“破魔刀”。怀玉篇中曾贯穿五条悟喉咙，是全作除黑绳外唯一能破防无下限术式的咒具。', NULL, 1, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_tool` VALUES (2, '游云', '⛓️', '特级咒具', 'top', '伏黑甚尔 → 夏油杰 → 禅院真希', '三节棍形态，唯一未被赋予术式的纯粹物理咒具。威力随使用者力量增长，天与咒缚者（甚尔、真希）方能发挥全部威力，最终在涩谷被破坏。', NULL, 2, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_tool` VALUES (3, '释魂刀', '🔪', '特级咒具', 'top', '伏黑甚尔', '价值五亿日元的妖刀，无视一切物体硬度、直接斩裂魂魄。需要一双能观测无生命体魂魄的眼睛，才能发挥十二分效果。', NULL, 3, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_tool` VALUES (4, '万里锁', '🔗', '等级未知', 'unknown', '伏黑甚尔', '锁链根部不被观察到即可无限延长的咒具，常与天逆鉾搭配，进行远距离的束缚与攻击。', NULL, 4, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_tool` VALUES (5, '狱门疆', '📦', '特级咒物', 'relic', '羂索', '得道高僧圆寂后的躯体，能将目标强制封印。涩谷事变中五条悟被它封入，后由“天使”的术式解开。', NULL, 5, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_tool` VALUES (6, '米格尔的黑绳', '🪢', '疑似特级咒具', 'maybe', '米格尔·奥杜尔', '诅咒师米格尔耗费数十年、以多种术式编织而成的绳索，能抵挡无下限术式，与天逆鉾并称可破“最强之防”的异物。', NULL, 6, '2026-11-09 08:58:17', '2026-11-09 08:58:17');
INSERT INTO `jjk_tool` VALUES (7, '咒具化的日本刀', '⚔️', '咒具化（进行中）', 'unknown', '三轮霞', '新阴流剑士三轮霞的爱刀。常年注入咒力而产生“咒具化”现象——咒具的诞生，本就始于咒力的长年灌溉。', NULL, 7, '2026-11-09 08:58:17', '2026-11-09 08:58:17');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '鐢ㄦ埛鍚',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '閭??',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '瀵嗙爜锛堟槑鏂囧瓨鍌?級',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'user' COMMENT '瑙掕壊锛歛dmin绠＄悊鍛?/ user鏅??鐢ㄦ埛锛堜繚鐣欏瓧娈碉紝鏉冮檺浠?permission 涓哄噯锛',
  `permission` int NOT NULL DEFAULT 1 COMMENT '鏉冮檺锛?绠＄悊鍛樻潈闄?/ 1榛樿?鏉冮檺锛堟敞鍐岀敤鎴烽粯璁?1锛',
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '鐢ㄦ埛琛' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', 'admin@test.com', '$2a$10$btxLlLhOGOOjEix/2wyF0u/hHB1vgOlAeGAsryKPXDYcd9Hl0GGDa', 'admin', 0, '2026-11-09 08:40:37', '2026-11-09 08:40:37');
INSERT INTO `sys_user` VALUES (2, '虎杖悠仁', NULL, '123456', 'user', 1, '2026-11-12 09:00:00', '2026-11-12 09:00:00');
INSERT INTO `sys_user` VALUES (3, '伏黑惠', NULL, '123456', 'user', 1, '2026-11-12 09:00:00', '2026-11-12 09:00:00');
INSERT INTO `sys_user` VALUES (4, '钉崎野蔷薇', NULL, '123456', 'user', 1, '2026-11-12 09:00:00', '2026-11-12 09:00:00');
INSERT INTO `sys_user` VALUES (5, '五条悟', NULL, '123456', 'user', 1, '2026-11-12 09:00:00', '2026-11-12 09:00:00');
INSERT INTO `sys_user` VALUES (6, '七海建人', NULL, '123456', 'user', 1, '2026-11-12 09:00:00', '2026-11-12 09:00:00');
INSERT INTO `sys_user` VALUES (7, '狗卷棘', NULL, '123456', 'user', 1, '2026-11-12 09:00:00', '2026-11-12 09:00:00');
INSERT INTO `sys_user` VALUES (8, '禅院真希', NULL, '123456', 'user', 1, '2026-11-12 09:00:00', '2026-11-12 09:00:00');
INSERT INTO `sys_user` VALUES (9, '乙骨忧太', NULL, '123456', 'user', 1, '2026-11-12 09:00:00', '2026-11-12 09:00:00');
INSERT INTO `sys_user` VALUES (10, '熊猫', NULL, '123456', 'user', 1, '2026-11-12 09:00:00', '2026-11-12 09:00:00');

SET FOREIGN_KEY_CHECKS = 1;
