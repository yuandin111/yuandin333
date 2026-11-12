-- MySQL dump 10.13  Distrib 8.0.39, for Win64 (x86_64)
--
-- Host: localhost    Database: springboot_test
-- ------------------------------------------------------
-- Server version	8.0.39

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `forum_comment`
--

DROP TABLE IF EXISTS `forum_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `forum_comment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `post_id` bigint NOT NULL COMMENT '帖子ID',
  `parent_id` bigint DEFAULT NULL COMMENT '被回复的评论ID，NULL 表示楼层主评',
  `reply_to_name` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '被回复者用户名',
  `user_id` bigint NOT NULL COMMENT '评论者ID',
  `user_name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '评论者用户名',
  `content` varchar(1000) COLLATE utf8mb4_general_ci NOT NULL COMMENT '评论内容',
  `like_count` int NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1正常 0已删除',
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_post` (`post_id`),
  KEY `idx_parent` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='论坛评论与回复';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forum_comment`
--

LOCK TABLES `forum_comment` WRITE;
/*!40000 ALTER TABLE `forum_comment` DISABLE KEYS */;
INSERT INTO `forum_comment` VALUES (1,1,NULL,NULL,2,'虎杖悠仁','先自荐一下《放学后的便利店》，写完才发现自己最想写的是那盒没人舍得喝的牛奶。',12,1,'2026-11-12 09:15:00'),(2,1,NULL,NULL,4,'钉崎野蔷薇','图绘区那两篇也太好看了，求索引里加一个「过程记录」分类！',8,1,'2026-11-12 09:18:00'),(3,1,2,'钉崎野蔷薇',1,'admin','收到，下次更新索引时加上，感谢建议。',5,1,'2026-11-12 09:20:00'),(4,2,NULL,NULL,3,'伏黑惠','「会有的」这三个字写得比一整段对话都重。',21,1,'2026-11-12 09:26:00'),(5,2,NULL,NULL,4,'钉崎野蔷薇','猜拳猜七轮这段太真实了，下次记得写我赢了。',16,1,'2026-11-12 09:29:00'),(6,2,5,'钉崎野蔷薇',2,'虎杖悠仁','可是最后是小票一起结的呀！',9,1,'2026-11-12 09:31:00'),(7,3,NULL,NULL,1,'admin','「自己愿意加的那三分钟」——这句收得太漂亮了。',18,1,'2026-11-12 09:40:00'),(8,3,NULL,NULL,5,'五条悟','可颂出现在七海老师的文里，合理又意外。',11,1,'2026-11-12 09:43:00'),(9,4,NULL,NULL,3,'伏黑惠','四十七粒灰尘这个设定，比直接写「最强」更有说服力。',27,1,'2026-11-12 09:52:00'),(10,4,NULL,NULL,9,'乙骨忧太','读到最后一段沉默了很久，收藏了。',14,1,'2026-11-12 09:56:00'),(11,5,NULL,NULL,10,'熊猫','那锅汤的配方我可以解释一下……算了还是不解释了。',19,1,'2026-11-12 10:06:00'),(12,6,NULL,NULL,7,'狗卷棘','鲑鱼。（意思是「纸的才叫清单」这句很对）',13,1,'2026-11-12 10:19:00'),(13,7,NULL,NULL,2,'虎杖悠仁','补充词条：金枪鱼之后如果加一句「明太子」，通常是「有人来了快把钱包收起来」。',22,1,'2026-11-12 10:32:00'),(14,8,NULL,NULL,4,'钉崎野蔷薇','只用线条撑压迫感这个思路学到了，求看完成版！',17,1,'2026-11-12 10:45:00'),(15,10,NULL,NULL,8,'禅院真希','同意归到「束缚」。术式可以关掉，天与咒缚关不掉，这个差别挺关键。',15,1,'2026-11-12 11:09:00'),(16,10,15,'禅院真希',1,'admin','「能不能关掉」这个判据很好，我没想到，收进考据区笔记了。',7,1,'2026-11-12 11:12:00'),(17,11,NULL,NULL,5,'五条悟','投真希一票。不过虎杖那条线的结尾留白也很有意思，不急着下结论。',12,1,'2026-11-12 11:22:00'),(18,12,NULL,NULL,6,'七海建人','槽位说 logically 更顺。补充一点：调伏失败后的空缺似乎不会被填补，这也支持「固定结构」的判断。',20,1,'2026-11-12 11:35:00'),(19,14,NULL,NULL,8,'禅院真希','我是那段没声音的走廊。后来每次路过学校后门都会想起。',10,1,'2026-11-12 11:59:00'),(22,16,NULL,NULL,9,'乙骨忧太','普通用户评论',0,1,'2026-11-12 14:41:32');
/*!40000 ALTER TABLE `forum_comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forum_like`
--

DROP TABLE IF EXISTS `forum_like`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `forum_like` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `post_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_post_user` (`post_id`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='帖子点赞（一人一帖一次）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forum_like`
--

LOCK TABLES `forum_like` WRITE;
/*!40000 ALTER TABLE `forum_like` DISABLE KEYS */;
/*!40000 ALTER TABLE `forum_like` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forum_post`
--

DROP TABLE IF EXISTS `forum_post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `forum_post` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '帖子ID',
  `title` varchar(120) COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题',
  `content` text COLLATE utf8mb4_general_ci NOT NULL COMMENT '正文',
  `category` varchar(32) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'fanwork' COMMENT '板块：fanwork同人二创/fanart同人图绘/discuss剧情讨论/lore术式考据/chat闲聊水区',
  `tags` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '标签，英文逗号分隔',
  `cover_url` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '封面图URL（可空，前端回退渐变卡片）',
  `author_id` bigint NOT NULL COMMENT '作者用户ID',
  `author_name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '作者用户名（冗余，避免列表联表）',
  `like_count` int NOT NULL DEFAULT '0' COMMENT '点赞数',
  `comment_count` int NOT NULL DEFAULT '0' COMMENT '评论数',
  `view_count` int NOT NULL DEFAULT '0' COMMENT '浏览量',
  `is_top` tinyint NOT NULL DEFAULT '0' COMMENT '是否置顶',
  `is_essence` tinyint NOT NULL DEFAULT '0' COMMENT '是否精华',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1正常 0已删除',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_author` (`author_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='论坛帖子';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forum_post`
--

LOCK TABLES `forum_post` WRITE;
/*!40000 ALTER TABLE `forum_post` DISABLE KEYS */;
INSERT INTO `forum_post` VALUES (1,'【置顶】同人二创索引贴 · 长期更新','欢迎来到高专社区的同人二创区！这里收原创短篇、连载、图绘和设定脑洞。\n\n发帖小约定：\n1. 标题请带上【同人】或【连载】前缀，方便检索；\n2. 涉及原作剧情走向的请标注剧透；\n3. 图绘请注明是否授权转载，本站鼓励原创；\n4. 友好交流，不攻击其他创作者。\n\n楼下可以自荐作品，我会定期把优质长篇补进索引。也欢迎大家在「剧情讨论」和「术式考据」区开枝散叶。','fanwork','置顶,公告,索引',NULL,1,'admin',64,3,1542,1,1,1,'2026-11-12 09:10:00','2026-11-12 09:10:00'),(2,'【同人】放学后的便利店','傍晚六点，高专后门的便利店自动门发出熟悉的叮咚声。\n\n虎杖把最后一盒草莓牛奶放进篮子，回头看见伏黑正站在杂志架前，手里拿着一本关于湿地生态的刊物，表情认真得像是准备召唤什么新式神。\n\n「你在选术式参考书吗？」\n「不是，只是这篇讲鹅的迁徙。」伏黑把书放回去，「玉犬最近对鸭子很感兴趣。」\n\n结账时钉崎从货架另一头探出头，举着两包限定口味的薯片：「猜拳，输的人请客。」\n\n于是三个人在收银台前猜了七轮，最后店员看不下去，默默把薯片扫码算进了同一张小票。\n\n回学校的路上天已经暗了，路灯把影子拉得很长。虎杖忽然说：「等以后不用出任务了，我们还能这样一起买牛奶吗？」\n\n伏黑没有立刻回答。风从街角吹过来，他把手插进口袋，点了点头。\n\n「会有的。」\n\n那盒草莓牛奶后来一直放在宿舍冰箱最上层，谁也没舍得喝。','fanwork','日常,虎杖,伏黑,钉崎,治愈',NULL,2,'虎杖悠仁',128,3,2085,0,1,1,'2026-11-12 09:22:00','2026-11-12 09:22:00'),(3,'【同人·短篇】七点三分的那班电车','七海建人习惯在七点三分开的车厢里坐靠窗第三个位置。\n\n这个时间人不多，光线刚好斜着落在折叠好的报纸上，面包店刚出炉的可颂还带一点温度。他把领带松开半寸，用十划经的思路把今天拆成七份，只留三份给工作。\n\n那天车厢对面坐了个背着书包的高专学生，制服袖口沾着灰，正对着一罐咖啡发呆。七海认得那种眼神——不是疲惫，是刚刚学会把某些东西默默收起来的眼神。\n\n他没有说话，只是在下车前把没动过的那袋可颂放在了座位边。\n\n后来他听说，那天的任务报告写得比往常都整齐。\n\n「加班是不合理的。」他曾经这样说。可有些班，是自己愿意加的那三分钟。','fanwork','七海,治愈,短篇,日常',NULL,6,'七海建人',96,2,1320,0,1,1,'2026-11-12 09:35:00','2026-11-12 09:35:00'),(4,'【同人】无量空处里的五分钟','如果信息真的无限，那最先被淹没的会是什么？\n\n五条悟曾在一个无聊的午后做过实验：闭上六眼，试着只去数教室里灰尘的数量。数到第四十七粒时他放弃了，不是数不清，而是太清楚了——清楚到每一粒灰尘上都映着一张学生的脸。\n\n「老师，你发什么呆？」虎杖在窗外挥手。\n\n「在想今天要不要提前下课。」\n\n「真的吗！」\n「假的。」\n\n他抬手把墨镜往上推了推，视线重新落回那些吵吵闹闹的人身上。无限的情报流里，唯独这几张脸不需要分析，也不会变成噪音。\n\n后来被封进狱门疆的时候，他想起的不是最强这个词，而是那四十七粒灰尘。\n\n五分钟很长，长到足够把一件事确认一遍：站在那儿的人，从来不是因为最强才留下来的。','fanwork','五条,脑洞,短篇,微刀',NULL,5,'五条悟',210,2,3150,0,1,1,'2026-11-12 09:48:00','2026-11-12 09:48:00'),(5,'【连载】高专的雨天（一）','雨是从第二天凌晨开始下的。\n\n伏黑被鵺拍窗户的声音叫醒，发现走廊尽头堆着几把伞，伞柄上贴着歪歪扭扭的纸条：「借用请登记 —— 钉崎」。登记栏里只有一行字，虎杖写着「借一把，还两把，因为捡到了一把没人要的」。\n\n玉犬缩在玄关，湿漉漉的尾巴把地砖扫出一小片水痕。他蹲下来擦了擦，影子里的水面忽然安静下来，像有人在里面轻轻合上了一本书。\n\n厨房亮着灯。熊猫正用极大的锅煮东西，说是「雨天应该喝点热的」，但谁也说不清锅里到底是什么。\n\n第一节：伞、影子，与一锅来历不明的汤。\n（未完待续）','fanwork','连载,高专,日常,伏黑',NULL,3,'伏黑惠',87,1,986,0,0,1,'2026-11-12 10:02:00','2026-11-12 10:02:00'),(6,'【同人】钉崎的东京购物清单','来东京第三个月，钉崎野蔷薇的购物清单已经写到第七页。\n\n第一页是必需品：锤子、备用钉、一副能挡雨的手套。第三页开始变得离谱：限定色指甲油、某家只在周三营业的古着店地址、据说能让拍照显脸小的发夹。最后一页只有一行字，是她自己加的——「给老家寄点东京的东西回去」。\n\n虎杖问她为什么不用手机记。「纸的才叫清单，」她把本子合上，「手机里那叫备忘录。」\n\n后来那本清单被夹在任务包里带回过一次涉谷，边角卷了起来。她没换新的，只是把第七页撕下来，重新抄了一遍。\n\n有些东西丢了要补，有些名字不能重写。','fanwork','钉崎,日常,东京,微刀',NULL,4,'钉崎野蔷薇',73,1,874,0,0,1,'2026-11-12 10:15:00','2026-11-12 10:15:00'),(7,'【同人】饭团语词典 · 增补版','应大家要求，整理一份高专内部通用的饭团语小词典（非官方，狗卷本人未审阅）：\n\n· 鲑鱼 = 没问题 / 收到\n· 昆布 = 辛苦了，先歇会儿\n· 梅干 = 不太妙，注意身后\n· 明太子 = 有人来了，装正常\n· 金枪鱼 = 我请客\n\n进阶用法：连续说两个鲑鱼通常表示「真的没问题，别再问了」；如果在鲑鱼之后沉默三秒，多半是「其实有点问题但不想让你担心」。\n\n补充一条来自熊猫的观察：狗卷棘说「金枪鱼」的时候，钱包通常已经掏出来了。\n\n（本词典持续增补，欢迎在评论区提交新词条。）','fanwork','狗卷,设定梗,轻松,词典',NULL,7,'狗卷棘',65,1,1102,0,0,1,'2026-11-12 10:28:00','2026-11-12 10:28:00'),(8,'【同人图】领域展开 · 线稿过程记录','这次画的是「领域展开」的一瞬间，用的是最普通的针管笔，没有贴图也没有特效层，想试试只用线条能不能撑起那种压迫感。\n\n过程记录：\n1. 先用三个同心圆定构图，最外圈故意画歪一点，让空间不那么规整；\n2. 中间那层符文参考了高专走廊地砖的纹样，做了简化；\n3. 人物只留一个剪影，越小越好，视线自然会被拉到圆心；\n4. 最后擦掉所有辅助线，只保留呼吸感的留白。\n\n画完才发现最费时间的不是符文，是把「静止」画出来。\n\n线稿和完成版都放在图包里，欢迎同好一起交流构图，转载请注明出处。','fanart','线稿,构图,原创图,过程',NULL,8,'禅院真希',152,1,1876,0,1,1,'2026-11-12 10:40:00','2026-11-12 10:40:00'),(9,'【同人图】乙骨与里香 · 色纸企划','一张小色纸，画的是没有战斗的下午。\n\n设定很简单：走廊、半开的窗、两个人份的便当。里香坐在稍微远一点的位置，裙摆被风带起来一点，乙骨正把筷子递过去。我刻意没画任何咒力光效，想让这一格看起来就是普通的一天。\n\n上色只用了三种蓝加一点暖灰，边缘留了纸本身的白。企划一共四张，这是第二张，后面两张想画雨天和夜里的操场。\n\n有同好在约互换色纸，感兴趣的可以在评论区留个言。','fanart','色纸,乙骨,里香,原创图',NULL,9,'乙骨忧太',118,0,1324,0,0,1,'2026-11-12 10:52:00','2026-11-12 10:52:00'),(10,'【讨论】「天与咒缚」到底算不算一种术式？','起因是重读怀玉篇时的一点疑惑：天与咒缚是先天束缚，用零咒力换肉体强度，那它在体系里应该归到「术式」，还是归到「束缚」这个更大的类别？\n\n我倾向后者。术式通常有可描述的发动条件与效果，而天与咒缚更像是对容器本身的限制条款，它不「发动」，它一直「存在」。\n\n但真希后期那个状态又让分类变复杂了——当束缚被进一步推到极限，人本身反而成了某种超越术式的东西。\n\n大家怎么看？有没有原作里更明确的措辞可以佐证？','discuss','天与咒缚,设定,讨论',NULL,1,'admin',42,2,764,0,0,1,'2026-11-12 11:05:00','2026-11-12 11:05:00'),(11,'【讨论】涩谷之后，谁的成长线最完整？','想聊聊成长线的完整性，不是比强弱，是看「变化有没有被好好写出来」。\n\n我个人投真希一票：从被家族定义，到亲手把那个定义拆掉，起点、转折、代价三段都很清楚。虎杖那条线则更沉一点，他的变化不太像升级，更像一次次把选择扛下来之后剩下的东西。\n\n伏黑和钉崎的线我觉得都还有留白，尤其钉崎，很多情绪是藏在日常细节里的，不喊出来反而更重。\n\n欢迎补充，尽量别吵强弱，聊叙事就好。','discuss','剧情,成长线,涩谷',NULL,10,'熊猫',56,1,908,0,0,1,'2026-11-12 11:18:00','2026-11-12 11:18:00'),(12,'【考据】十种影法术的式神数量真的只有十种吗','整理一下目前能确认的式神：玉犬（黑白）、鵺、大蛇、蟾蜍、满象、贯牛、虎葬，加上最后那只，数字上确实接近十。\n\n但「十种」这个名字究竟是数量上限，还是某种术式结构的代称？有几个细节值得注意：\n· 影子是媒介，术式本身更像「调伏」而非「召唤」；\n· 被调伏的式神被击溃后不会复原，这个代价和数量上限是两件事；\n· 领域里出现的多重影子，更像是同一套结构的展开，而不是新增个体。\n\n所以我的猜测是：十种指可被调伏的「槽位」，而不是式神的物种清单。欢迎拿原作分镜来打我脸。','lore','十种影法术,伏黑,考据',NULL,3,'伏黑惠',88,1,1421,0,1,1,'2026-11-12 11:30:00','2026-11-12 11:30:00'),(13,'【考据】从「共鸣」看咒具与术式的边界','钉崎的共鸣很有意思：它必须借助媒介（钉、锤、稻草人），但造成伤害的位置不在媒介上，而在目标身上。\n\n这让它在分类上卡在一个很微妙的地方——施术对象是「关系」，不是物体。同类思路还能看到咒具化的日本刀：长期注入咒力让器物本身产生变化，器物于是从工具慢慢变成了术式的一部分。\n\n如果按这个方向推，咒具和术式可能不是两类东西，而是同一条轴上的不同刻度：一端是纯工具，一端是几乎长在术师身上的东西。\n\n欢迎补充其他例子，尤其是黑绳那类。','lore','共鸣,咒具,钉崎,设定',NULL,4,'钉崎野蔷薇',39,0,613,0,0,1,'2026-11-12 11:42:00','2026-11-12 11:42:00'),(14,'【水楼】深夜说说你第一次被吓到的镜头','不是比谁胆子大，就聊聊「第一次意识到这部的气氛不太对」是哪一个瞬间。\n\n我先来：是某集里走廊尽头的灯一盏一盏灭掉，但画面完全没给声音。当时下意识把音量调小了，结果更安静，反而更慌。\n\n楼下的别剧透后面剧情哈，聊镜头就好。','chat','闲聊,水楼,氛围',NULL,2,'虎杖悠仁',31,1,530,0,0,1,'2026-11-12 11:55:00','2026-11-12 11:55:00'),(16,'【链路测试】普通用户发帖','验证普通账号能否发表言论。','fanwork','测试',NULL,9,'乙骨忧太',0,1,0,0,0,0,'2026-11-12 14:41:32','2026-11-12 14:41:32');
/*!40000 ALTER TABLE `forum_post` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `friend_message`
--

DROP TABLE IF EXISTS `friend_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friend_message` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `from_user_id` bigint NOT NULL,
  `to_user_id` bigint NOT NULL,
  `content` varchar(1000) COLLATE utf8mb4_general_ci NOT NULL,
  `is_read` tinyint NOT NULL DEFAULT '0' COMMENT '0未读 1已读',
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_pair` (`from_user_id`,`to_user_id`,`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='好友私信';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friend_message`
--

LOCK TABLES `friend_message` WRITE;
/*!40000 ALTER TABLE `friend_message` DISABLE KEYS */;
INSERT INTO `friend_message` VALUES (1,2,1,'管理员老师，索引贴我把便利店那篇自荐上去了～',1,'2026-11-12 09:16:00'),(2,1,2,'看到啦，写得很稳，已经加进精华候选。',1,'2026-11-12 09:17:00'),(3,2,1,'谢谢！连载区那边我也想开个坑，回头发你看看。',1,'2026-11-12 09:19:00'),(4,5,1,'放学后的便利店，我投一票年度最佳。',1,'2026-11-12 10:00:00'),(5,1,5,'最强老师也看同人区啊。',1,'2026-11-12 10:01:00'),(6,5,1,'当然，毕竟是学生写的。',0,'2026-11-12 10:02:00');
/*!40000 ALTER TABLE `friend_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `friend_request`
--

DROP TABLE IF EXISTS `friend_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friend_request` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `from_user_id` bigint NOT NULL COMMENT '发起人',
  `from_user_name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `to_user_id` bigint NOT NULL COMMENT '接收人',
  `to_user_name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `message` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '验证消息',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '0待处理 1已同意 2已拒绝',
  `create_time` datetime DEFAULT NULL,
  `handle_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_to` (`to_user_id`,`status`),
  KEY `idx_from` (`from_user_id`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='好友申请';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friend_request`
--

LOCK TABLES `friend_request` WRITE;
/*!40000 ALTER TABLE `friend_request` DISABLE KEYS */;
INSERT INTO `friend_request` VALUES (1,7,'狗卷棘',1,'admin','鲑鱼！想加个好友一起整理饭团语词典。',2,'2026-11-12 11:00:00','2026-11-12 14:38:59'),(2,6,'七海建人',1,'admin','看到考据区那篇，想聊聊束缚分类。',2,'2026-11-12 11:20:00','2026-11-12 14:38:58'),(3,1,'admin',9,'乙骨忧太','色纸企划很好看，交个好友吧！',0,'2026-11-12 11:40:00',NULL),(4,8,'禅院真希',2,'虎杖悠仁','同人图区互换色纸吗？',1,'2026-11-12 08:30:00','2026-11-12 08:40:00');
/*!40000 ALTER TABLE `friend_request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `friendship`
--

DROP TABLE IF EXISTS `friendship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friendship` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `friend_id` bigint NOT NULL,
  `friend_name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_friend` (`user_id`,`friend_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='好友关系';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friendship`
--

LOCK TABLES `friendship` WRITE;
/*!40000 ALTER TABLE `friendship` DISABLE KEYS */;
INSERT INTO `friendship` VALUES (9,2,3,'伏黑惠','2026-11-12 09:09:00'),(10,3,2,'虎杖悠仁','2026-11-12 09:09:00'),(11,4,5,'五条悟','2026-11-12 09:10:00'),(12,5,4,'钉崎野蔷薇','2026-11-12 09:10:00');
/*!40000 ALTER TABLE `friendship` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jjk_character`
--

DROP TABLE IF EXISTS `jjk_character`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jjk_character` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '人物名',
  `icon` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '图标emoji',
  `role` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '身份/称号',
  `camp` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'school' COMMENT '阵营：school高专 / curse咒灵·诅咒师',
  `ability` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '术式/能力',
  `tags` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '关键词，英文逗号分隔',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '详细介绍',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '配图URL，无图前端回退emoji',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序，越小越靠前',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='人物志';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jjk_character`
--

LOCK TABLES `jjk_character` WRITE;
/*!40000 ALTER TABLE `jjk_character` DISABLE KEYS */;
INSERT INTO `jjk_character` VALUES (1,'虎杖悠仁','👊','东京校一年级','school','超人体质 · 宿傩容器','主角,容器','为完成爷爷“帮助他人”的遗愿，吞下特级咒物“宿傩手指”的少年。身体能力与咒力总量远超常人，性格直率善良，越是绝境越会为他人挥拳。',NULL,1,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(2,'伏黑惠','🐕','东京校一年级','school','十种影法术','式神','禅院家分家出身的冷静战术派，以式神（玉犬、鵺、大蛇等）布阵取胜。嘴上说着功利，行动却始终站在保护同伴的那一侧。',NULL,2,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(3,'钉崎野蔷薇','🔨','东京校一年级','school','共鸣','锤与钉','从乡村来到东京的自信少女，以钉子与锤子为武器。讨厌被轻视，战斗直觉与意志力都极其出色，飒爽又鲜活。',NULL,3,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(4,'五条悟','😎','特级咒术师 · 教师','school','无下限术式 · 领域「无量空处」','现代最强,六眼','现代最强咒术师，天生“六眼”持有者。护短、爱胡闹、实力深不可测；涩谷事变中被羂索以狱门疆封印，成为整个局势的转折点。',NULL,4,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(5,'七海建人','☕','一级咒术师','school','十划经','社畜,七三','厌恶加班的前金融精英，习惯以“七三”比例分析目标弱点。沉稳可靠的职场前辈，涩谷事变中战死于真人之手。',NULL,5,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(6,'家入硝子','💊','东京校校医','school','反转术式','治疗','高专最强的“医生”，以反转术式治愈咒术造成的伤口。毒舌又可靠，是学生们最后的保险。',NULL,6,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(7,'乙骨忧太','🗡️','特级咒术师','school','复制 · 里香','前传主角','前传主角，与过咒怨灵“里香”立下婚约的特级术师，能复制他人术式。涩谷之后担任虎杖的“处刑人”，实则与五条一系并肩。',NULL,7,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(8,'夏油杰','🌑','前特级咒术师','curse','咒灵操术','挚友','五条悟的昔日挚友，因理念相悖叛离高专，发动“百鬼夜行”。死后躯体被羂索夺取，沦为阴谋的皮囊。',NULL,8,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(9,'东堂葵','💪','京都校三年级','school','不义游戏','体操','前体操选手，热血耿直的前辈，信奉“交到一百个朋友”。拍手即可交换物体位置，涩谷中为救虎杖付出一臂。',NULL,9,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(10,'禅院真希','⚔️','东京校二年级','school','天与咒缚','体术','禅院家分家出身，以零咒力换取超凡体能的剑士。后突破束缚成为完全体，挥舞特级咒具“游云”大闹禅院家。',NULL,10,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(11,'狗卷棘','🍙','东京校二年级','school','咒言','语言','语言即咒术的术师，平时用饭团配料示意咒言效果。沉默寡言，却总在关键时刻挡在同伴身前。',NULL,11,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(12,'熊猫','🐼','东京校二年级','school','咒骸','夜蛾造物','夜蛾校长制造的自主思考咒骸，大哥型角色。肉体强悍、核心众多，是队伍里可靠的重型战力。',NULL,12,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(13,'伏黑甚尔','🔪','术师杀手','curse','天与咒缚 · 咒具运用','惠之父','伏黑惠之父，零咒力的传说暗杀者。咒具运用出神入化，曾以天逆鉾重创五条悟，并成功刺杀星浆体天内理子。',NULL,13,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(14,'真人','🎭','特级咒灵','curse','无为转变','改造灵魂','由人类对自身的诅咒诞生的咒灵，能改造灵魂、重塑肉体。视人命为玩具，涩谷事变的核心凶手之一。',NULL,14,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(15,'两面宿傩','👹','诅咒之王','curse','解 · 捌 · 领域「伏魔御厨子」','千年最强','千年前的最强术师，死后化为二十根特级咒物手指。寄宿于虎杖体内，冷静、残酷、唯我独尊，等待复活之日。',NULL,15,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(16,'羂索','🧠','千年术师','curse','咒灵操术 · 夺舍','幕后黑手','不断更换身体的千年阴谋家，现占据夏油杰的躯体。以“死灭回游”收集咒力，编织波及全日本的巨大漩涡。',NULL,16,'2026-11-09 08:58:17','2026-11-09 08:58:17');
/*!40000 ALTER TABLE `jjk_character` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jjk_event`
--

DROP TABLE IF EXISTS `jjk_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jjk_event` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `era` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '时代/时间',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '事件标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '详细介绍',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '配图URL，无图前端回退emoji',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序，越小越靠前',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='重要事件时间线';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jjk_event`
--

LOCK TABLES `jjk_event` WRITE;
/*!40000 ALTER TABLE `jjk_event` DISABLE KEYS */;
INSERT INTO `jjk_event` VALUES (1,'约千年以前','咒术全盛时代 · 宿傩之死','诅咒之王两面宿傩横行于世，死后化为二十根手指散落千年，成为咒术界最高机密——特级咒物。',NULL,1,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(2,'怀玉 · 玉折','星浆体暗杀与挚友分岐','五条悟与夏油杰的高专时代。术师杀手伏黑甚尔刺杀星浆体天内理子后被五条击毙；理念相悖的二人，自此走向不同的道路。',NULL,2,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(3,'前传 · 0卷','百鬼夜行','夏油杰发动“百鬼夜行”，欲消灭所有非术师。转学生乙骨忧太与里香挺身而出将其阻止，里香得以成佛。',NULL,3,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(4,'2018年','宿傩容器诞生','虎杖悠仁为救同学吞下宿傩手指，成为“容器”进入东京咒术高专，并在少年院事件中首次与宿傩直面。',NULL,4,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(5,'2018年','交流会与牺牲','京都姊妹校交流会明争暗斗；吉野顺平被真人诱入歧途；花御来袭，究极机械丸战死——少年们付出成长的代价。',NULL,5,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(6,'2018 · 10月31日','渋谷事变','万圣节之夜，涩谷被“帐”覆盖。五条悟遭狱门疆封印，七海建人战死，钉崎野蔷薇濒死，东堂断臂——咒术界根基动摇。',NULL,6,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(7,'2018 · 11月','死灭回游开幕','羂索启动全国结界猎杀游戏，津美纪被卷入其中。禅院家灭门、真希突破天与咒缚；高专众人为救人兼寻解封之法参战。',NULL,7,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(8,'终局','新宿决战','“天使”解开狱门疆，五条悟回归，与占据伏黑惠身体的宿傩展开跨时代决战并战死。虎杖以灵魂一击驱散诅咒之王，以人与人的联结收场。',NULL,8,'2026-11-09 08:58:17','2026-11-09 08:58:17');
/*!40000 ALTER TABLE `jjk_event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jjk_tool`
--

DROP TABLE IF EXISTS `jjk_tool`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jjk_tool` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '咒具名',
  `icon` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '图标emoji',
  `grade` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '等级文字，如：特级咒具',
  `grade_class` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'unknown' COMMENT '等级样式：top/relic/maybe/unknown',
  `owner` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '持有者',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '详细介绍',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '配图URL，无图前端回退emoji',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序，越小越靠前',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='咒具图鉴';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jjk_tool`
--

LOCK TABLES `jjk_tool` WRITE;
/*!40000 ALTER TABLE `jjk_tool` DISABLE KEYS */;
INSERT INTO `jjk_tool` VALUES (1,'天逆鉾','🗡️','特级咒具','top','伏黑甚尔 → 被五条悟没收封印','十手状胁差，可强制解除发动中的术式，堪称“破魔刀”。怀玉篇中曾贯穿五条悟喉咙，是全作除黑绳外唯一能破防无下限术式的咒具。',NULL,1,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(2,'游云','⛓️','特级咒具','top','伏黑甚尔 → 夏油杰 → 禅院真希','三节棍形态，唯一未被赋予术式的纯粹物理咒具。威力随使用者力量增长，天与咒缚者（甚尔、真希）方能发挥全部威力，最终在涩谷被破坏。',NULL,2,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(3,'释魂刀','🔪','特级咒具','top','伏黑甚尔','价值五亿日元的妖刀，无视一切物体硬度、直接斩裂魂魄。需要一双能观测无生命体魂魄的眼睛，才能发挥十二分效果。',NULL,3,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(4,'万里锁','🔗','等级未知','unknown','伏黑甚尔','锁链根部不被观察到即可无限延长的咒具，常与天逆鉾搭配，进行远距离的束缚与攻击。',NULL,4,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(5,'狱门疆','📦','特级咒物','relic','羂索','得道高僧圆寂后的躯体，能将目标强制封印。涩谷事变中五条悟被它封入，后由“天使”的术式解开。',NULL,5,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(6,'米格尔的黑绳','🪢','疑似特级咒具','maybe','米格尔·奥杜尔','诅咒师米格尔耗费数十年、以多种术式编织而成的绳索，能抵挡无下限术式，与天逆鉾并称可破“最强之防”的异物。',NULL,6,'2026-11-09 08:58:17','2026-11-09 08:58:17'),(7,'咒具化的日本刀','⚔️','咒具化（进行中）','unknown','三轮霞','新阴流剑士三轮霞的爱刀。常年注入咒力而产生“咒具化”现象——咒具的诞生，本就始于咒力的长年灌溉。',NULL,7,'2026-11-09 08:58:17','2026-11-09 08:58:17');
/*!40000 ALTER TABLE `jjk_tool` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `username` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '鐢ㄦ埛鍚',
  `email` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '閭??',
  `password` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '瀵嗙爜锛堟槑鏂囧瓨鍌?級',
  `role` varchar(20) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'user' COMMENT '瑙掕壊锛歛dmin绠＄悊鍛?/ user鏅??鐢ㄦ埛锛堜繚鐣欏瓧娈碉紝鏉冮檺浠?permission 涓哄噯锛',
  `permission` int NOT NULL DEFAULT '1' COMMENT '鏉冮檺锛?绠＄悊鍛樻潈闄?/ 1榛樿?鏉冮檺锛堟敞鍐岀敤鎴烽粯璁?1锛',
  `create_time` datetime DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='鐢ㄦ埛琛';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES (1,'admin','admin@test.com','$2a$10$/UFgeuNa0VlM9.kQNNt.hOxRWxMZhIb8KdsvWD.KN.Vc8aN0j/MAO','admin',0,'2026-11-12 13:51:34','2026-11-12 13:51:34'),(2,'虎杖悠仁',NULL,'123456','user',1,'2026-11-12 09:00:00','2026-11-12 09:00:00'),(3,'伏黑惠',NULL,'123456','user',1,'2026-11-12 09:00:00','2026-11-12 09:00:00'),(4,'钉崎野蔷薇',NULL,'123456','user',1,'2026-11-12 09:00:00','2026-11-12 09:00:00'),(5,'五条悟',NULL,'123456','user',1,'2026-11-12 09:00:00','2026-11-12 09:00:00'),(6,'七海建人',NULL,'123456','user',1,'2026-11-12 09:00:00','2026-11-12 09:00:00'),(7,'狗卷棘',NULL,'$2a$10$V0jdWrKwl..2dRKZBfTNyOOmB2TmU2FE9p/qqhA.BanIvd0OVvpJK','user',1,'2026-11-12 09:00:00','2026-11-12 09:00:00'),(8,'禅院真希',NULL,'123456','user',1,'2026-11-12 09:00:00','2026-11-12 09:00:00'),(9,'乙骨忧太',NULL,'$2a$10$hBNdY7EDqcrxycE8fNWHhOCRXYIKV.4getSUtSX37d.xKp4KjsMh2','user',1,'2026-11-12 09:00:00','2026-11-12 09:00:00'),(10,'熊猫',NULL,'123456','user',1,'2026-11-12 09:00:00','2026-11-12 09:00:00');
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-12 14:47:52
