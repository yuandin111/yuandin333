# -*- coding: utf-8 -*-
"""
读取 springboot_test 真实数据，生成自包含 HTML 数据报表（浅色主题、无外部依赖）。
运行：python 生成数据报表.py
"""
import os
import json
import html
import subprocess
from collections import Counter, defaultdict
from datetime import datetime

MYSQL = r"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
DB = "springboot_test"
BASE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(BASE, "数据库数据报表_20261119.html")


def query(sql):
    cmd = [MYSQL, "-uroot", "-p123456", "--default-character-set=utf8mb4",
           "-D", DB, "-N", "-B", "-e", sql]
    r = subprocess.run(cmd, capture_output=True)
    if r.returncode != 0:
        raise RuntimeError(r.stderr.decode("utf-8", "replace"))
    out = r.stdout.decode("utf-8", "replace").strip()
    return json.loads(out) if out else []


posts = query("SELECT JSON_ARRAYAGG(JSON_OBJECT('id',id,'title',title,'category',category,'author',author_name,'likes',like_count,'comments',comment_count,'views',view_count,'top',is_top,'essence',is_essence,'time',create_time)) FROM forum_post;")
comments = query("SELECT JSON_ARRAYAGG(JSON_OBJECT('id',id,'post',post_id,'parent',parent_id,'replyTo',reply_to_name,'user',user_name,'content',content,'likes',like_count,'time',create_time,'status',status)) FROM forum_comment;")
likes = query("SELECT JSON_ARRAYAGG(JSON_OBJECT('post',post_id,'user',user_id,'time',create_time)) FROM forum_like;")
users = query("SELECT JSON_ARRAYAGG(JSON_OBJECT('id',id,'name',username,'perm',permission)) FROM sys_user;")
others = query("SELECT JSON_ARRAYAGG(JSON_OBJECT('k',k,'n',n)) FROM (SELECT '人物' AS k, COUNT(*) AS n FROM jjk_character UNION ALL SELECT '事件',COUNT(*) FROM jjk_event UNION ALL SELECT '咒具',COUNT(*) FROM jjk_tool) t;")

CAT = {"discuss": "剧情讨论", "lore": "术式考据", "fanwork": "同人二创", "fanart": "同人图绘", "chat": "闲聊水区"}
CAT_COLOR = {"discuss": "#2563eb", "lore": "#7c3aed", "fanwork": "#db2777", "fanart": "#ea580c", "chat": "#0891b2"}
e = html.escape

total_posts = len(posts)
total_comments = len([c for c in comments if c["status"] == 1])
total_likes = len(likes)
total_views = sum(p["views"] for p in posts)
total_users = len(users)

# 分类统计
cat_cnt = Counter(p["category"] for p in posts)
cat_like = Counter()
cat_comment = Counter()
for p in posts:
    cat_like[p["category"]] += p["likes"]
    cat_comment[p["category"]] += p["comments"]

# 用户活跃：发帖 / 评论 / 获赞
user_post = Counter(p["author"] for p in posts)
user_comment = Counter(c["user"] for c in comments if c["status"] == 1)
uid2name = {u["id"]: u["name"] for u in users}
user_like_given = Counter(uid2name.get(l["user"], l["user"]) for l in likes)
author_like = Counter()
for p in posts:
    author_like[p["author"]] += p["likes"]
user_names = sorted(set(list(user_post) + list(user_comment) + list(user_like_given)))
activity = []
for n in user_names:
    activity.append({"name": n, "post": user_post[n], "comment": user_comment[n],
                     "like": user_like_given[n], "got": author_like[n]})
activity.sort(key=lambda x: -(x["post"] + x["comment"] + x["like"]))

# 帖子按热度排序
hot_posts = sorted(posts, key=lambda p: -(p["likes"] * 3 + p["comments"] * 2 + p["views"] * 0.05))
# 评论按获赞排序
top_comments = sorted([c for c in comments if c["status"] == 1], key=lambda c: -c["likes"])[:15]

# 时间线（按天）
day_post = Counter(str(p["time"])[:10] for p in posts)
day_comment = Counter(str(c["time"])[:10] for c in comments if c["status"] == 1)
days = sorted(set(list(day_post) + list(day_comment)))

# 最新评论
recent_comments = sorted([c for c in comments if c["status"] == 1], key=lambda c: str(c["time"]), reverse=True)[:12]
post_title = {p["id"]: p["title"] for p in posts}


def bar_rows(counter, total, colors=None):
    parts = []
    for k, v in sorted(counter.items(), key=lambda x: -x[1]):
        pct = v / total * 100 if total else 0
        color = colors.get(k, "#64748b") if colors else "#6366f1"
        parts.append(
            '<div class="bar-row"><div class="bar-label">%s</div>'
            '<div class="bar-track"><div class="bar-fill" style="width:%.1f%%;background:%s"></div></div>'
            '<div class="bar-num">%d</div></div>' % (e(str(k)), pct, color, v))
    return "\n".join(parts)


kpis = [
    ("帖子总数", total_posts, "📝", "#2563eb"),
    ("评论总数", total_comments, "💬", "#7c3aed"),
    ("点赞总数", total_likes, "❤️", "#db2777"),
    ("累计浏览", total_views, "👁️", "#ea580c"),
    ("注册用户", total_users, "👥", "#0891b2"),
]
kpi_html = "\n".join(
    '<div class="kpi"><div class="kpi-icon" style="background:%s1a">%s</div>'
    '<div class="kpi-body"><div class="kpi-num">%s</div><div class="kpi-label">%s</div></div></div>'
    % (color, icon, f"{num:,}", label) for label, num, icon, color in kpis)

cat_bars = bar_rows({CAT.get(k, k): v for k, v in cat_cnt.items()}, total_posts,
                    {CAT.get(k, k): CAT_COLOR.get(k, "#64748b") for k in cat_cnt})

# 帖子明细表
post_rows = []
for p in hot_posts:
    tag = '<span class="pill" style="background:%s1a;color:%s">%s</span>' % (
        CAT_COLOR.get(p["category"], "#64748b"), CAT_COLOR.get(p["category"], "#64748b"),
        CAT.get(p["category"], p["category"]))
    marks = ("⭐" if p["top"] else "") + (" ✨" if p["essence"] else "")
    title = e(str(p["title"])) + (" <span class='mark'>%s</span>" % marks if marks else "")
    post_rows.append(
        "<tr><td class='idx'>%d</td><td class='title'>%s</td><td>%s</td><td>%s</td>"
        "<td class='num'>%d</td><td class='num'>%d</td><td class='num'>%d</td><td class='date'>%s</td></tr>" % (
            p["id"], title, tag, e(str(p["author"])), p["likes"], p["comments"], p["views"],
            str(p["time"])[5:16]))

# 用户活跃表
act_rows = []
for a in activity:
    tot = a["post"] + a["comment"] + a["like"]
    act_rows.append(
        "<tr><td>%s</td><td class='num'>%d</td><td class='num'>%d</td><td class='num'>%d</td>"
        "<td class='num'>%d</td><td class='num total'>%d</td></tr>" % (
            e(a["name"]), a["post"], a["comment"], a["like"], a["got"], tot))

# 热评
hot_comment_html = []
for c in top_comments:
    reply = ("<span class='reply'>↳ 回复 @%s</span>" % e(str(c["replyTo"]))) if c["replyTo"] else ""
    hot_comment_html.append(
        "<div class='cmt'><div class='cmt-head'><b>%s</b> %s <span class='cmt-likes'>♥ %d</span></div>"
        "<div class='cmt-post'>在《%s》</div><div class='cmt-body'>%s</div></div>" % (
            e(str(c["user"])), reply, c["likes"], e(str(post_title.get(c["post"], "已删除帖子"))),
            e(str(c["content"]))))

# 最新评论
recent_html = []
for c in recent_comments:
    tag = "<span class='time'>%s</span>" % str(c["time"])[5:16]
    recent_html.append("<li><b>%s</b> 评论了《%s》 %s<div class='rc-body'>%s</div></li>" % (
        e(str(c["user"])), e(str(post_title.get(c["post"], "已删除帖子"))), tag, e(str(c["content"]))))

# 时间线
timeline_html = []
maxv = max([day_post[d] + day_comment[d] for d in days] or [1])
for d in days:
    v = day_post[d] + day_comment[d]
    timeline_html.append(
        "<div class='tl-row'><span class='tl-day'>%s</span>"
        "<div class='tl-track'><div class='tl-bar' style='width:%.0f%%'></div></div>"
        "<span class='tl-num'>%d</span></div>" % (d[5:], v / maxv * 100, v))

others_html = " · ".join("%s <b>%s</b>" % (e(str(r["k"])), r["n"]) for r in others)
gen_time = datetime.now().strftime("%Y-%m-%d %H:%M")

CSS = """
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:"Microsoft YaHei","PingFang SC",system-ui,sans-serif;background:#f1f5f9;color:#1e293b;line-height:1.6;padding:32px 20px}
.wrap{max-width:1080px;margin:0 auto}
.header{background:linear-gradient(135deg,#4f46e5,#7c3aed);color:#fff;border-radius:18px;padding:34px 38px;box-shadow:0 10px 30px rgba(79,70,229,.18)}
.header h1{font-size:27px;font-weight:700;letter-spacing:.5px}
.header p{opacity:.85;font-size:13px;margin-top:8px}
.header .sub{margin-top:14px;display:inline-block;background:rgba(255,255,255,.18);padding:5px 14px;border-radius:20px;font-size:12px}
.kpis{display:grid;grid-template-columns:repeat(5,1fr);gap:14px;margin:22px 0}
.kpi{background:#fff;border-radius:14px;padding:18px 16px;display:flex;align-items:center;gap:12px;box-shadow:0 2px 10px rgba(0,0,0,.04)}
.kpi-icon{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:22px;flex-shrink:0}
.kpi-num{font-size:24px;font-weight:700;color:#0f172a;line-height:1.1}
.kpi-label{font-size:12px;color:#64748b;margin-top:2px}
.grid{display:grid;grid-template-columns:1fr 1fr;gap:18px;margin-bottom:18px}
.card{background:#fff;border-radius:14px;padding:22px 24px;box-shadow:0 2px 10px rgba(0,0,0,.04)}
.card h2{font-size:15px;font-weight:700;color:#0f172a;margin-bottom:16px;padding-left:10px;border-left:3px solid #6366f1}
.card h2 small{font-weight:400;color:#94a3b8;font-size:11px;margin-left:8px}
.bar-row{display:flex;align-items:center;gap:10px;margin:9px 0;font-size:12px}
.bar-label{width:74px;flex-shrink:0;color:#475569}
.bar-track{flex:1;height:9px;background:#f1f5f9;border-radius:6px;overflow:hidden}
.bar-fill{height:100%;border-radius:6px}
.bar-num{width:30px;text-align:right;font-weight:600;color:#334155}
.full{grid-column:1/-1}
table{width:100%;border-collapse:collapse;font-size:12px}
th{background:#f8fafc;color:#64748b;font-weight:600;text-align:left;padding:9px 10px;white-space:nowrap}
td{padding:9px 10px;border-bottom:1px solid #f1f5f9}
tr:hover td{background:#fafbff}
.idx{color:#94a3b8;width:30px}
.title{font-weight:600;color:#1e293b;max-width:360px}
.mark{color:#f59e0b;font-size:11px}
.num{text-align:right;font-variant-numeric:tabular-nums;font-weight:600;color:#334155}
.num.total{color:#4f46e5;font-size:13px}
.date{color:#94a3b8;white-space:nowrap;font-size:11px}
.pill{padding:2px 9px;border-radius:12px;font-size:11px;white-space:nowrap}
.cmt{padding:12px 0;border-bottom:1px solid #f1f5f9}
.cmt:last-child{border-bottom:none}
.cmt-head{font-size:13px}
.cmt-head b{color:#4f46e5}
.reply{color:#94a3b8;font-size:11px;margin-left:6px}
.cmt-likes{float:right;color:#db2777;font-size:12px;font-weight:600}
.cmt-post{font-size:11px;color:#94a3b8;margin:3px 0}
.cmt-body,.rc-body{font-size:12px;color:#334155;background:#f8fafc;padding:8px 11px;border-radius:8px;margin-top:4px}
.tl-row{display:flex;align-items:center;gap:10px;margin:7px 0;font-size:12px}
.tl-day{width:48px;color:#64748b}
.tl-track{flex:1;height:14px;background:#f1f5f9;border-radius:4px;overflow:hidden}
.tl-bar{height:100%;background:linear-gradient(90deg,#818cf8,#6366f1);border-radius:4px}
.tl-num{width:24px;text-align:right;color:#334155;font-weight:600}
ul.recent{list-style:none}
ul.recent li{padding:9px 0;border-bottom:1px solid #f1f5f9;font-size:12px}
ul.recent li:last-child{border:none}
.time{color:#94a3b8;font-size:11px;margin-left:6px}
.footer{text-align:center;color:#94a3b8;font-size:11px;margin:24px 0 8px}
@media(max-width:800px){.kpis{grid-template-columns:repeat(2,1fr)}.grid{grid-template-columns:1fr}}
"""

HTML = """<!DOCTYPE html>
<html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>论坛数据库数据报表</title><style>%s</style></head><body><div class="wrap">
<div class="header"><h1>📊 论坛数据库数据报表</h1>
<p>springboot_test · 帖子 / 评论 / 点赞 / 用户互动全景</p>
<div class="sub">生成时间：%s · 数据源：本地 MySQL 实时查询</div></div>

<div class="kpis">%s</div>

<div class="grid">
<div class="card"><h2>板块内容分布<small>共 %d 篇帖子</small></h2>%s</div>
<div class="card"><h2>互动时间线<small>按天统计发帖 + 评论</small></h2>%s</div>

<div class="card full"><h2>帖子互动排行<small>按 点赞×3 + 评论×2 + 浏览×0.05 排序</small></h2>
<table><thead><tr><th>#</th><th>标题</th><th>板块</th><th>作者</th><th>点赞</th><th>评论</th><th>浏览</th><th>发布时间</th></tr></thead>
<tbody>%s</tbody></table></div>

<div class="card"><h2>用户活跃度<small>发帖 / 评论 / 点赞 / 获赞</small></h2>
<table><thead><tr><th>用户</th><th>发帖</th><th>评论</th><th>点赞</th><th>获赞</th><th>活跃合计</th></tr></thead>
<tbody>%s</tbody></table></div>

<div class="card"><h2>热门评论 TOP15<small>按评论获赞数排序</small></h2>%s</div>

<div class="card full"><h2>最新评论<small>最近 12 条</small></h2><ul class="recent">%s</ul></div>

<div class="card full"><h2>内容库概览<small>后台管理内容</small></h2><div style="font-size:14px;color:#475569">%s</div></div>
</div>

<div class="footer">本报告由 项目/生成数据报表.py 自动生成 · 数据全部来自 springboot_test 实时查询</div>
</div></body></html>
""" % (CSS, gen_time, kpi_html, total_posts, cat_bars, "\n".join(timeline_html),
       "\n".join(post_rows), "\n".join(act_rows), "\n".join(hot_comment_html),
       "\n".join(recent_html), others_html)

with open(OUT, "w", encoding="utf-8") as f:
    f.write(HTML)
print("报表已生成:", OUT)
print("统计: 帖子%d 评论%d 点赞%d 浏览%d 用户%d" % (total_posts, total_comments, total_likes, total_views, total_users))
