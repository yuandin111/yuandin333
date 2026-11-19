# -*- coding: utf-8 -*-
"""
为 forum_post 批量生成真实感的评论 / 点赞 / 浏览量。
- 评论内容按帖子主题定制，含主评与楼层回复（parent_id / reply_to_name）
- 点赞遵守 uk_post_user（一人一帖一次），排除作者本人
- 同步 forum_post 的 like_count / comment_count / view_count
生成物：sql/seed_interactions_20261119.sql（UTF-8，可直接用 mysql 导入）
"""
import os
import random
from datetime import datetime, timedelta

random.seed(20261119)
OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sql")
OUT = os.path.join(OUT_DIR, "seed_interactions_20261119.sql")

# 用户：id -> 名字
U = {
    1: "admin", 2: "虎杖悠仁", 3: "伏黑惠", 4: "钉崎野蔷薇", 5: "五条悟",
    6: "七海建人", 7: "狗卷棘", 8: "禅院真希", 9: "乙骨忧太", 10: "熊猫",
}
NAME2ID = {v: k for k, v in U.items()}

# 帖子元数据：id -> (作者, 发布时间, 分类)
POSTS = {
    1: ("admin", "2026-11-13 20:10:00", "discuss"),
    2: ("伏黑惠", "2026-11-13 21:05:00", "discuss"),
    3: ("五条悟", "2026-11-14 10:30:00", "discuss"),
    4: ("虎杖悠仁", "2026-11-14 14:20:00", "discuss"),
    5: ("乙骨忧太", "2026-11-14 19:40:00", "discuss"),
    6: ("伏黑惠", "2026-11-14 21:15:00", "discuss"),
    7: ("钉崎野蔷薇", "2026-11-15 09:30:00", "discuss"),
    8: ("禅院真希", "2026-11-15 11:00:00", "discuss"),
    9: ("七海建人", "2026-11-15 15:20:00", "discuss"),
    10: ("五条悟", "2026-11-15 18:45:00", "discuss"),
    11: ("admin", "2026-11-15 20:00:00", "lore"),
    12: ("伏黑惠", "2026-11-16 08:40:00", "lore"),
    13: ("禅院真希", "2026-11-16 09:10:00", "lore"),
    14: ("钉崎野蔷薇", "2026-11-16 09:40:00", "lore"),
    15: ("虎杖悠仁", "2026-11-15 12:30:00", "fanwork"),
    16: ("七海建人", "2026-11-15 17:00:00", "fanwork"),
    17: ("狗卷棘", "2026-11-15 21:30:00", "fanwork"),
    18: ("乙骨忧太", "2026-11-16 08:00:00", "fanwork"),
    19: ("伏黑惠", "2026-11-16 09:20:00", "fanwork"),
    20: ("熊猫", "2026-11-15 14:10:00", "fanart"),
    21: ("禅院真希", "2026-11-15 19:20:00", "fanart"),
    22: ("钉崎野蔷薇", "2026-11-16 08:30:00", "fanart"),
    23: ("虎杖悠仁", "2026-11-15 22:40:00", "chat"),
    24: ("狗卷棘", "2026-11-16 09:00:00", "chat"),
}

# 每篇帖子的评论：(用户名, 内容, 回复第几条评论(0基, None=主评))
COMMENTS = {
    1: [
        ("五条悟", "拿天气当倒计时这个读法有意思。不过那天我确实觉得闷得反常，原来不是错觉。", None),
        ("钉崎野蔷薇", "湿度这个细节绝了，重看的时候完全没往那边想，作者埋得是真深。", None),
        ("虎杖悠仁", "所以那时候大家其实都已经不舒服了，只是谁都没往那边想……", None),
        ("七海建人", "「环境先于事件」这个说法我记下了，后面几篇可以拿这个当尺子量一量。", None),
    ],
    2: [
        ("伏黑惠", "把追加规则理解成束缚条款，这个角度我确实没想到。", None),
        ("虎杖悠仁", "那羂索自己是不是也被自己设的束缚反噬了？", None),
        ("乙骨忧太", "赢的方式和设局的方式是同一种——这句总结得很准。", 1),
        ("熊猫", "规则战篇重看一遍，感觉完全是两个故事了。", None),
    ],
    3: [
        ("钉崎野蔷薇", "「怀玉不是回忆杀，是考题」——这句可以直接当本帖结论了。", None),
        ("虎杖悠仁", "考题……那我们所有人都是答卷上的字。", 0),
        ("伏黑惠", "嗯。", 0),
        ("七海建人", "同一个问题的两种答案，逼着后来每个人都得选边，这结构确实像轴。", None),
    ],
    4: [
        ("虎杖悠仁", "「被现实改写」这个说法……确实，我从来没自己想通过。", None),
        ("钉崎野蔷薇", "但正因为是被改写的，才显得真实吧。想通了反而不像人。", 0),
        ("五条悟", "成长不是变强，这句不错。 teachable。", None),
        ("禅院真希", "从「阻止死」到「背负着走下去」，这个递进我认。", None),
    ],
    5: [
        ("乙骨忧太", "被说得这么重要，压力有点大。", None),
        ("熊猫", "替五条补位这个说法，作为同级生深有同感。", None),
        ("伏黑惠", "早一话晚一话都不行，时机确实卡得死。", None),
        ("狗卷棘", "鲑鱼。（意思是：这段确实好看）", None),
    ],
    6: [
        ("虎杖悠仁", "那次我说「你救过我」的时候，其实也没想那么多。", None),
        ("钉崎野蔷薇", "允许自己被救，这点比什么新术式都难。", 0),
        ("禅院真希", "影法术的边界和人的边界一起拓宽，这个对仗写得好。", None),
        ("七海建人", "先做减法以免太疼——这个心理我很熟悉。", None),
    ],
    7: [
        ("钉崎野蔷薇", "终于有人懂了！我不是在硬撑，我本来就这样。", None),
        ("虎杖悠仁", "「出厂设置就完整」这个形容太准了，羡慕。", 0),
        ("伏黑惠", "……嗯。", 0),
        ("熊猫", "心里没有裂缝要补，锤子就只砸别人，逻辑闭环了。", None),
    ],
    8: [
        ("禅院真希", "把评价体系整个掀翻，比证明「我也能有咒力」痛快多了。", None),
        ("钉崎野蔷薇", "真依那一段我真的哭爆。", 0),
        ("七海建人", "把「被定义」改写成「自定义」，这个词用得漂亮。", None),
        ("虎杖悠仁", "所以她挥游云的时候，是在替自己出气吧。", None),
    ],
    9: [
        ("七海建人", "被说得这么清楚，有点不好意思。不过「停止假装还有别的选择」确实是这样。", None),
        ("虎杖悠仁", "七海先生那句遗言我一直记着。", 0),
        ("熊猫", "第一次辞职是理性，第二次是自愿，这个对比太工整了。", None),
        ("乙骨忧太", "成年人成长不是变热血，是认清代价后还愿意留下。", None),
    ],
    10: [
        ("五条悟", "最强救不了所有人——嗯，这句我认。", None),
        ("乙骨忧太", "当老师是给自己找的、不用独自站在顶端的方式……受教了。", 0),
        ("狗卷棘", "鲑鱼。（意思是：写得好）", None),
        ("虎杖悠仁", "所以狱门疆里他最放不下的是教室，突然就说通了。", None),
    ],
    11: [
        ("禅院真希", "游云的「特」不在锋利而在封存的术式，这个解释我认。", None),
        ("伏黑惠", "每件特级咒具都是一位无名术师的领域残骸——这个推论很妙。", None),
        ("熊猫", "那按这个逻辑，我的咒骸是不是也能算某种残骸？", 1),
        ("五条悟", "下次带游云来，我给你演示一下什么叫点火。", 0),
    ],
    12: [
        ("伏黑惠", "一个对付结果，一个对付过程，这下清楚多了。", None),
        ("五条悟", "黑绳那次我可没吃亏哦。", 0),
        ("七海建人", "对抗系咒具背后有一套独立知识树，这条线原作确实挖得浅。", None),
        ("钉崎野蔷薇", "所以我的共鸣也走的是「过程」那一挂？", 2),
    ],
    13: [
        ("禅院真希", "长枪、三节棍、刀——被你这么一排，我自己的成长刻度都清楚了。", None),
        ("钉崎野蔷薇", "咒具是术师的外置器官，这个比喻我要收藏。", 0),
        ("虎杖悠仁", "不再频繁换器官，说明长成了。好戳。", 1),
        ("熊猫", "那我是不是一辈子都在换核心……", 1),
    ],
    14: [
        ("钉崎野蔷薇", "基站这个说法太形象了，我就说锤子随便换也没关系。", None),
        ("五条悟", "同一柄锤子用到老会咒具化，这个猜想有意思。", 0),
        ("熊猫", "那我的饭团是不是也算媒介……", 0),
        ("伏黑惠", "关键在咒力流向，不器物本身，讲得清楚。", None),
    ],
    15: [
        ("虎杖悠仁", "「那朵花看起来比较饿」——我确实说过这话！", None),
        ("伏黑惠", "……粉笔灰那段是编的。", 0),
        ("狗卷棘", "金枪鱼。（意思是：那朵花我看见了）", 0),
        ("熊猫", "公告栏最下面那行字我也记得，后来一直没人擦。", None),
    ],
    16: [
        ("七海建人", "法棍掰一半那段是虚构的。不过周五确实是我最松的时候。", None),
        ("乙骨忧太", "被学生撞见还分半根法棍，七海先生其实很温柔。", 0),
        ("虎杖悠仁", "「七三开」那段看得我鼻子一酸。", None),
        ("钉崎野蔷薇", "周五限定的法棍，两个人分也还是完整的——结尾绝了。", None),
    ],
    17: [
        ("狗卷棘", "鲑鱼。（意思是：那张登记表真有过）", None),
        ("熊猫", "「饭团类借出概不追讨」那条是我提的！", 0),
        ("虎杖悠仁", "读到「算了，当我请的」突然被戳到。", 0),
        ("乙骨忧太", "年末扫除写成这样，太治愈了。", None),
    ],
    18: [
        ("乙骨忧太", "……写得太细了，我没什么好说的。", None),
        ("熊猫", "深蓝色便当盒是真事，我作证。", 0),
        ("钉崎野蔷薇", "「咸了吗，下次少放点盐」这句我受不了。", None),
        ("虎杖悠仁", " wind吹窗帘那段，像谁伸手按住了它——好温柔。", None),
    ],
    19: [
        ("伏黑惠", "那把伞确实在伞架最里面。", None),
        ("虎杖悠仁", "那锅汤到底是什么啊！！快点更新。", None),
        ("狗卷棘", "明太子。（意思是：期待下一节）", None),
        ("熊猫", "「影子里的话，要等到放晴」，这句词好美。", 1),
    ],
    20: [
        ("熊猫", "两只犬的背影画得真好，留白绝了。", None),
        ("禅院真希", "水彩越想控制越不听，这个心得我记下了。", 0),
        ("钉崎野蔷薇", "壁纸自取已存，署名放心。", None),
        ("虎杖悠仁", "雨声全靠颜色的「湿」来表现，太会了。", None),
    ],
    21: [
        ("禅院真希", "潜水照片这个参照物找得妙，光线被介质吃掉的感觉确实是通的。", None),
        ("五条悟", "无量空处用负空间来画，很合适嘛。", 0),
        ("虎杖悠仁", "期待「领域从内部被打破」那张！", None),
        ("钉崎野蔷薇", "压迫感不来自画了多少而来自空了多少——受教。", None),
    ],
    22: [
        ("钉崎野蔷薇", "跟阿姨交涉多一勺咖喱是我日常，被看见了。", None),
        ("虎杖悠仁", "三人的筷子同时伸向最后一块炸鸡，太真实了哈哈。", 0),
        ("狗卷棘", "鲑鱼。（意思是：给我也留两格）", None),
        ("熊猫", "二年级组我也预定两格。", 2),
    ],
    23: [
        ("虎杖悠仁", "避难人群里那个披外套的大叔，我也反复看了好几遍。", None),
        ("七海建人", "普通人的下意识，这才是灾难场景里真正的锚点。", 0),
        ("熊猫", "我投一格：把伞让出去却自己淋雨的学生。", None),
        ("钉崎野蔷薇", "只能说一格？那我说那个把最后一块面包掰开的孩子。", 2),
        ("禅院真希", "说多了算犯规，那我就只说「那一格」。", None),
    ],
    24: [
        ("狗卷棘", "料理部不许笑。", None),
        ("虎杖悠仁", "田径部会被所有部门借人，这个设定太对了。", 0),
        ("伏黑惠", "生物部的观察日记……我考虑一下。", None),
        ("乙骨忧太", "我报名料理部，跟狗卷一起。", 1),
        ("熊猫", "那我裁判部，专门判定谁又抢了最后一块炸鸡。", 2),
    ],
}

def esc(s):
    return s.replace("'", "''")

lines = [
    "-- 互动数据种子：评论 / 点赞 / 浏览量",
    "-- 由 项目/生成互动数据.py 生成于 2026-11-19，可重复导入（先清理本批数据）",
    "SET NAMES utf8mb4;",
    "START TRANSACTION;",
    "",
    "-- 清理：本脚本生成的记录 id 从 1000 起，重复导入时先清掉，绝不触碰用户真实数据(id<1000)",
    "DELETE FROM forum_like WHERE id >= 1000;",
    "DELETE FROM forum_comment WHERE id >= 1000;",
    "",
]

comment_id = 1000
like_id = 1000
comment_rows = []
like_rows = []
count_updates = []

for pid, (author, post_time, category) in POSTS.items():
    base = datetime.strptime(post_time, "%Y-%m-%d %H:%M:%S")
    items = COMMENTS[pid]
    # 评论
    local_ids = []
    for i, (uname, content, reply_idx) in enumerate(items):
        comment_id += 1
        local_ids.append(comment_id)
        uid = NAME2ID[uname]
        t = base + timedelta(hours=2, minutes=7 + i * 23)
        if reply_idx is None:
            parent_id, reply_to = "NULL", "NULL"
        else:
            parent_id = str(local_ids[reply_idx])
            reply_to = "'%s'" % esc(items[reply_idx][0])
        comment_rows.append(
            "(%d, %d, %s, %s, %d, '%s', '%s', %d, 1, '%s')" % (
                comment_id, pid, parent_id, reply_to, uid, esc(uname), esc(content),
                random.randint(0, 6), t.strftime("%Y-%m-%d %H:%M:%S")))
    # 点赞：排除作者本人与管理员(避免与库中历史测试点赞 14-1 撞唯一键)，随机 4~8 人
    candidates = [uid for uid in U if U[uid] != author and uid != 1]
    likers = random.sample(candidates, random.randint(4, min(8, len(candidates))))
    for j, uid in enumerate(likers):
        like_id += 1
        t = base + timedelta(hours=1, minutes=11 + j * 19)
        like_rows.append("(%d, %d, %d, '%s')" % (
            like_id, pid, uid, t.strftime("%Y-%m-%d %H:%M:%S")))
    view = random.randint(48, 420)
    count_updates.append(
        "UPDATE forum_post SET like_count=%d, comment_count=%d, view_count=%d WHERE id=%d;" % (
            len(likers), len(items), view, pid))

# 用真实表数据重新校准所有帖子的计数（含原有的 2 条历史评论，保证绝对一致）
count_updates.append(
    "UPDATE forum_post p SET "
    "comment_count=(SELECT COUNT(*) FROM forum_comment c WHERE c.post_id=p.id AND c.status=1), "
    "like_count=(SELECT COUNT(*) FROM forum_like l WHERE l.post_id=p.id);")

lines.append("INSERT INTO forum_comment (id,post_id,parent_id,reply_to_name,user_id,user_name,content,like_count,status,create_time) VALUES")
lines.append(",\n".join(comment_rows) + ";")
lines.append("")
lines.append("INSERT INTO forum_like (id,post_id,user_id,create_time) VALUES")
lines.append(",\n".join(like_rows) + ";")
lines.append("")
lines.append("-- 同步帖子计数")
lines.extend(count_updates)
lines.append("COMMIT;")
lines.append("")
lines.append("-- 校验：SELECT (SELECT COUNT(*) FROM forum_comment) AS comments, (SELECT COUNT(*) FROM forum_like) AS likes;")

os.makedirs(OUT_DIR, exist_ok=True)
with open(OUT, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))

print("生成完成:", OUT)
print("评论数:", len(comment_rows), " 点赞数:", len(like_rows), " 帖子数:", len(count_updates))
