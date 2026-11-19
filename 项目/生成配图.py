# -*- coding: utf-8 -*-
"""
零依赖配图生成器：为帖子封面、人物、事件、咒具生成风格统一的渐变 SVG。
- 图片写入 springBootTest/uploads/，通过 /uploads/** 对外访问
- 数据库存 /uploads/xxx.svg 路径，前端 resolveUrl 自动拼后端地址
- 幂等：重复执行覆盖同名文件、覆盖数据库路径字段
"""
import os
import re
import subprocess
import urllib.parse

MYSQL = r"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
DB = "springboot_test"
BASE = os.path.dirname(os.path.abspath(__file__))
UPLOADS = os.path.join(BASE, "springBootTest", "uploads")
os.makedirs(UPLOADS, exist_ok=True)


def q(sql):
    r = subprocess.run([MYSQL, "-uroot", "-p123456", "--default-character-set=utf8mb4",
                        "-D", DB, "-N", "-B", "-e", sql], capture_output=True)
    if r.returncode != 0:
        raise RuntimeError(r.stderr.decode("utf-8", "replace"))
    return r.stdout.decode("utf-8", "replace").strip()


def esc(s):
    return (s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))


# 分类 -> 双色渐变 + 主题符号
THEMES = {
    "discuss": ("#4f46e5", "#7c3aed", "剧情讨论"),
    "lore": ("#7c3aed", "#c026d3", "术式考据"),
    "fanwork": ("#db2777", "#f43f5e", "同人二创"),
    "fanart": ("#ea580c", "#f59e0b", "同人图绘"),
    "chat": ("#0891b2", "#06b6d4", "闲聊水区"),
}
CAMP = {"school": ("#2563eb", "#38bdf8"), "curse": ("#7c3aed", "#db2777")}


def gradient_svg(w, h, c1, c2, label, sub="", glyph=""):
    """通用渐变卡片：斜向双色渐变 + 网格点缀 + 大号符号 + 标题"""
    gid = re.sub(r"\W", "", c1 + c2)[:12]
    grid = "".join(
        '<line x1="%d" y1="0" x2="%d" y2="%d" stroke="#fff" stroke-opacity=".07"/>' % (x, x, h)
        for x in range(0, w, 48)) + "".join(
        '<line x1="0" y1="%d" x2="%d" y2="%d" stroke="#fff" stroke-opacity=".07"/>' % (y, w, y)
        for y in range(0, h, 48))
    sub_svg = ('<text x="%d" y="%d" fill="#fff" fill-opacity=".75" font-size="20" '
               'font-family="sans-serif">%s</text>' % (w // 2, h - 46, esc(sub))) if sub else ""
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">'
        '<defs><linearGradient id="g%s" x1="0" y1="0" x2="1" y2="1">'
        '<stop offset="0" stop-color="%s"/><stop offset="1" stop-color="%s"/>'
        '</linearGradient></defs>'
        '<rect width="%d" height="%d" fill="url(#g%s)"/>%s'
        '<circle cx="%d" cy="%d" r="%d" fill="#fff" fill-opacity=".08"/>'
        '<circle cx="%d" cy="%d" r="%d" fill="#fff" fill-opacity=".06"/>'
        '<text x="%d" y="%d" fill="#fff" font-size="%d" text-anchor="middle" '
        'font-family="sans-serif">%s</text>'
        '<text x="%d" y="%d" fill="#fff" font-size="30" font-weight="bold" text-anchor="middle" '
        'font-family="sans-serif">%s</text>%s</svg>'
    ) % (w, h, w, h, gid, c1, c2, w, h, gid, grid,
         int(w * 0.12), int(h * 0.18), int(w * 0.18),
         int(w * 0.85), int(h * 0.75), int(h * 0.1),
         w // 2, int(h * 0.55), int(min(w / max(len(glyph), 1) * 1.5, 120)), esc(glyph),
         w // 2, int(h * 0.55) + 46, esc(label), sub_svg)


def save(name, svg):
    path = os.path.join(UPLOADS, name)
    with open(path, "w", encoding="utf-8") as f:
        f.write(svg)
    return "/uploads/" + urllib.parse.quote(name)


# ===== 1. 帖子封面 =====
posts = [line.split("\t") for line in q(
    "SELECT id,category,title FROM forum_post ORDER BY id;").splitlines()]
post_sql = []
for pid, cat, title in posts:
    c1, c2, catname = THEMES.get(cat, THEMES["fanwork"])
    short = title[:14]
    url = save("post_%s.svg" % pid, gradient_svg(1200, 630, c1, c2, short, "JJK 同人论坛", "✦"))
    post_sql.append("UPDATE forum_post SET cover_url='%s' WHERE id=%s;" % (url, pid))

# ===== 2. 人物 =====
chars = [line.split("\t") for line in q(
    "SELECT id,name,icon,camp FROM jjk_character ORDER BY sort;").splitlines()]
char_sql = []
for cid, name, icon, camp in chars:
    c1, c2 = CAMP.get(camp, CAMP["school"])
    url = save("char_%s.svg" % cid, gradient_svg(600, 800, c1, c2, name, "东京咒术高专", icon or "✦"))
    char_sql.append("UPDATE jjk_character SET image_url='%s' WHERE id=%s;" % (url, cid))

# ===== 3. 事件 =====
events = [line.split("\t") for line in q(
    "SELECT id,title,era FROM jjk_event ORDER BY sort;").splitlines()]
event_sql = []
for eid, title, era in events:
    ancient = any(k in (era or "") for k in ("千年", "怀玉", "前传"))
    c1, c2 = ("#0f766e", "#0ea5e9") if ancient else ("#be123c", "#f97316")
    url = save("event_%s.svg" % eid, gradient_svg(800, 600, c1, c2, title[:16], era or "", "◷"))
    event_sql.append("UPDATE jjk_event SET image_url='%s' WHERE id=%s;" % (url, eid))

# ===== 4. 咒具 =====
tools = [line.split("\t") for line in q(
    "SELECT id,name,icon FROM jjk_tool ORDER BY sort;").splitlines()]
tool_sql = []
for tid, name, icon in tools:
    c1, c2 = ("#a16207", "#ea580c")
    url = save("tool_%s.svg" % tid, gradient_svg(600, 600, c1, c2, name, "特级咒具", icon or "⚔"))
    tool_sql.append("UPDATE jjk_tool SET image_url='%s' WHERE id=%s;" % (url, tid))

sql = "\n".join(post_sql + char_sql + event_sql + tool_sql)
out = os.path.join(BASE, "sql", "apply_cover_images_20261119.sql")
with open(out, "w", encoding="utf-8") as f:
    f.write("-- 配图路径回写（由 生成配图.py 生成）\nSET NAMES utf8mb4;\n" + sql + "\n")
r = subprocess.run([MYSQL, "-uroot", "-p123456", "--default-character-set=utf8mb4",
                    "-D", DB], input=sql.encode("utf-8"), capture_output=True)
if r.returncode != 0:
    raise RuntimeError(r.stderr.decode("utf-8", "replace"))

print("生成 SVG:", len(posts) + len(chars) + len(events) + len(tools), "张")
print("  帖子封面", len(posts), "人物", len(chars), "事件", len(events), "咒具", len(tools))
print("写入目录:", UPLOADS)
print("回写SQL:", out)
