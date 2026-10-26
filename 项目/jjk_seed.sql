-- ============================================================
-- 咒术回战资料站 - 内容数据初始化脚本
-- 库：springboot_test
-- 表：jjk_character / jjk_tool / jjk_event
-- 字段对齐后端实体 JjkCharacter / JjkTool / JjkEvent
--   （desc 字段在库中列名为 description，id 自增，含 sort 排序）
-- 说明：DROP 仅为保证脚本可重复执行，三张表均为新增表，无数据风险
-- ============================================================

USE springboot_test;
SET NAMES utf8mb4;

-- ===================== 人物志 =====================
DROP TABLE IF EXISTS jjk_character;
CREATE TABLE jjk_character (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  name          VARCHAR(50)  NOT NULL,
  icon          VARCHAR(16)  DEFAULT NULL,
  role          VARCHAR(100) DEFAULT NULL,
  camp          VARCHAR(20)  DEFAULT NULL,
  ability       VARCHAR(200) DEFAULT NULL,
  tags          VARCHAR(200) DEFAULT NULL,
  description   TEXT,
  sort          INT          DEFAULT 0,
  create_time   DATETIME     DEFAULT NULL,
  update_time   DATETIME     DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO jjk_character (name, icon, role, camp, ability, tags, description, sort, create_time, update_time) VALUES
('虎杖悠仁','👊','东京校一年级','school','超人体质 · 宿傩容器','主角, 容器','为完成爷爷“帮助他人”的遗愿，吞下特级咒物“宿傩手指”的少年。身体能力与咒力总量远超常人，性格直率善良，越是绝境越会为他人挥拳。',1,NOW(),NOW()),
('伏黑惠','🐕','东京校一年级','school','十种影法术','式神','禅院家分家出身的冷静战术派，以式神（玉犬、鵺、大蛇等）布阵取胜。嘴上说着功利，行动却始终站在保护同伴的那一侧。',2,NOW(),NOW()),
('钉崎野蔷薇','🔨','东京校一年级','school','共鸣','锤与钉','从乡村来到东京的自信少女，以钉子与锤子为武器。讨厌被轻视，战斗直觉与意志力都极其出色，飒爽又鲜活。',3,NOW(),NOW()),
('五条悟','😎','特级咒术师 · 教师','school','无下限术式 · 领域「无量空处」','现代最强, 六眼','现代最强咒术师，天生“六眼”持有者。护短、爱胡闹、实力深不可测；涩谷事变中被羂索以狱门疆封印，成为整个局势的转折点。',4,NOW(),NOW()),
('七海建人','☕','一级咒术师','school','十划经','社畜, 七三','厌恶加班的前金融精英，习惯以“七三”比例分析目标弱点。沉稳可靠的职场前辈，涩谷事变中战死于真人之手。',5,NOW(),NOW()),
('家入硝子','💊','东京校校医','school','反转术式','治疗','高专最强的“医生”，以反转术式治愈咒术造成的伤口。毒舌又可靠，是学生们最后的保险。',6,NOW(),NOW()),
('乙骨忧太','🗡️','特级咒术师','school','复制 · 里香','前传主角','前传主角，与过咒怨灵“里香”立下婚约的特级术师，能复制他人术式。涩谷之后担任虎杖的“处刑人”，实则与五条一系并肩。',7,NOW(),NOW()),
('夏油杰','🌑','前特级咒术师','curse','咒灵操术','挚友','五条悟的昔日挚友，因理念相悖叛离高专，发动“百鬼夜行”。死后躯体被羂索夺取，沦为阴谋的皮囊。',8,NOW(),NOW()),
('东堂葵','💪','京都校三年级','school','不义游戏','体操','前体操选手，热血耿直的前辈，信奉“交到一百个朋友”。拍手即可交换物体位置，涩谷中为救虎杖付出一臂。',9,NOW(),NOW()),
('禅院真希','⚔️','东京校二年级','school','天与咒缚','体术','禅院家分家出身，以零咒力换取超凡体能的剑士。后突破束缚成为完全体，挥舞特级咒具“游云”大闹禅院家。',10,NOW(),NOW()),
('狗卷棘','🍙','东京校二年级','school','咒言','语言','语言即咒术的术师，平时用饭团配料示意咒言效果。沉默寡言，却总在关键时刻挡在同伴身前。',11,NOW(),NOW()),
('熊猫','🐼','东京校二年级','school','咒骸','夜蛾造物','夜蛾校长制造的自主思考咒骸，大哥型角色。肉体强悍、核心众多，是队伍里可靠的重型战力。',12,NOW(),NOW()),
('伏黑甚尔','🔪','术师杀手','curse','天与咒缚 · 咒具运用','惠之父','伏黑惠之父，零咒力的传说暗杀者。咒具运用出神入化，曾以天逆鉾重创五条悟，并成功刺杀星浆体天内理子。',13,NOW(),NOW()),
('真人','🎭','特级咒灵','curse','无为转变','改造灵魂','由人类对自身的诅咒诞生的咒灵，能改造灵魂、重塑肉体。视人命为玩具，涩谷事变的核心凶手之一。',14,NOW(),NOW()),
('两面宿傩','👹','诅咒之王','curse','解 · 捌 · 领域「伏魔御厨子」','千年最强','千年前的最强术师，死后化为二十根特级咒物手指。寄宿于虎杖体内，冷静、残酷、唯我独尊，等待复活之日。',15,NOW(),NOW()),
('羂索','🧠','千年术师','curse','咒灵操术 · 夺舍','幕后黑手','不断更换身体的千年阴谋家，现占据夏油杰的躯体。以“死灭回游”收集咒力，编织波及全日本的巨大漩涡。',16,NOW(),NOW());

-- ===================== 咒具图鉴 =====================
DROP TABLE IF EXISTS jjk_tool;
CREATE TABLE jjk_tool (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  name          VARCHAR(50)  NOT NULL,
  icon          VARCHAR(16)  DEFAULT NULL,
  grade         VARCHAR(50)  DEFAULT NULL,
  grade_class   VARCHAR(20)  DEFAULT NULL,
  owner         VARCHAR(200) DEFAULT NULL,
  description   TEXT,
  sort          INT          DEFAULT 0,
  create_time   DATETIME     DEFAULT NULL,
  update_time   DATETIME     DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO jjk_tool (name, icon, grade, grade_class, owner, description, sort, create_time, update_time) VALUES
('天逆鉾','🗡️','特级咒具','top','伏黑甚尔 → 被五条悟没收封印','十手状胁差，可强制解除发动中的术式，堪称“破魔刀”。怀玉篇中曾贯穿五条悟喉咙，是全作除黑绳外唯一能破防无下限术式的咒具。',1,NOW(),NOW()),
('游云','⛓️','特级咒具','top','伏黑甚尔 → 夏油杰 → 禅院真希','三节棍形态，唯一未被赋予术式的纯粹物理咒具。威力随使用者力量增长，天与咒缚者（甚尔、真希）方能发挥全部威力，最终在涩谷被破坏。',2,NOW(),NOW()),
('释魂刀','🔪','特级咒具','top','伏黑甚尔','价值五亿日元的妖刀，无视一切物体硬度、直接斩裂魂魄。需要一双能观测无生命体魂魄的眼睛，才能发挥十二分效果。',3,NOW(),NOW()),
('万里锁','🔗','等级未知','unknown','伏黑甚尔','锁链根部不被观察到即可无限延长的咒具，常与天逆鉾搭配，进行远距离的束缚与攻击。',4,NOW(),NOW()),
('狱门疆','📦','特级咒物','relic','羂索','得道高僧圆寂后的躯体，能将目标强制封印。涩谷事变中五条悟被它封入，后由“天使”的术式解开。',5,NOW(),NOW()),
('米格尔的黑绳','🪢','疑似特级咒具','maybe','米格尔·奥杜尔','诅咒师米格尔耗费数十年、以多种术式编织而成的绳索，能抵挡无下限术式，与天逆鉾并称可破“最强之防”的异物。',6,NOW(),NOW()),
('咒具化的日本刀','⚔️','咒具化（进行中）','unknown','三轮霞','新阴流剑士三轮霞的爱刀。常年注入咒力而产生“咒具化”现象——咒具的诞生，本就始于咒力的长年灌溉。',7,NOW(),NOW());

-- ===================== 时间线事件 =====================
DROP TABLE IF EXISTS jjk_event;
CREATE TABLE jjk_event (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  era           VARCHAR(50)  DEFAULT NULL,
  title         VARCHAR(100) NOT NULL,
  description   TEXT,
  sort          INT          DEFAULT 0,
  create_time   DATETIME     DEFAULT NULL,
  update_time   DATETIME     DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO jjk_event (era, title, description, sort, create_time, update_time) VALUES
('约千年以前','咒术全盛时代 · 宿傩之死','诅咒之王两面宿傩横行于世，死后化为二十根手指散落千年，成为咒术界最高机密——特级咒物。',1,NOW(),NOW()),
('怀玉 · 玉折','星浆体暗杀与挚友分岐','五条悟与夏油杰的高专时代。术师杀手伏黑甚尔刺杀星浆体天内理子后被五条击毙；理念相悖的二人，自此走向不同的道路。',2,NOW(),NOW()),
('前传 · 0卷','百鬼夜行','夏油杰发动“百鬼夜行”，欲消灭所有非术师。转学生乙骨忧太与里香挺身而出将其阻止，里香得以成佛。',3,NOW(),NOW()),
('2018年','宿傩容器诞生','虎杖悠仁为救同学吞下宿傩手指，成为“容器”进入东京咒术高专，并在少年院事件中首次与宿傩直面。',4,NOW(),NOW()),
('2018年','交流与牺牲','京都姊妹校交流会明争暗斗；吉野顺平被真人诱入歧途；花御来袭，究极机械丸战死——少年们付出成长的代价。',5,NOW(),NOW()),
('2018 · 10月31日','渋谷事变','万圣节之夜，涩谷被“帐”覆盖。五条悟遭狱门疆封印，七海建人战死，钉崎野蔷薇濒死，东堂断臂——咒术界根基动摇。',6,NOW(),NOW()),
('2018 · 11月','死灭回游开幕','羂索启动全国结界猎杀游戏，津美纪被卷入其中。禅院家灭门、真希突破天与咒缚；高专众人为救人兼寻解封之法参战。',7,NOW(),NOW()),
('终局','新宿决战','“天使”解开狱门疆，五条悟回归，与占据伏黑惠身体的宿傩展开跨时代决战并战死。虎杖以灵魂一击驱散诅咒之王，以人与人的联结收场。',8,NOW(),NOW());
