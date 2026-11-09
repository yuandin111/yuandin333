# -*- coding: utf-8 -*-
"""修复 jjk_seed.sql 中因 UTF-8 被误当 GBK 解码导致的二次编码乱码。"""
import re
import sys

SRC = r'D:\workSpace\yuandin333\项目\jjk_seed.sql'
DST = r'D:\workSpace\yuandin333\项目\jjk_seed_fixed.sql'

text = open(SRC, 'rb').read().decode('utf-8')

def try_fix(cand: str):
    """候选串 GBK 编码回字节再 UTF-8 解码；返回 (结果, 是否完全成功)。"""
    try:
        b = cand.encode('gb18030')
    except UnicodeEncodeError:
        return None, False
    try:
        return b.decode('utf-8'), True
    except UnicodeDecodeError:
        # 有损还原（被污染的 '?' 字节无法恢复）
        return b.decode('utf-8', errors='replace'), False

# 乱码段 = 连续非 ASCII 字符，中间可能夹 '?' 或全角符号
pattern = re.compile(r'[^\x00-\x7f]+(?:\?+[^\x00-\x7f]*)*')

out = []
pos = 0
lossy = 0
for m in pattern.finditer(text):
    if m.start() < pos:
        continue
    seg = m.group()
    if not any(ord(c) > 127 for c in seg):
        continue
    following = text[m.end():m.end() + 3]
    best, take, ok = None, 0, False
    for t in range(0, len(following) + 1):
        fixed, good = try_fix(seg + following[:t])
        if fixed is not None:
            best, take, ok = fixed, t, good
            if good:
                break
    if best is None:
        best, take = seg, 0
    else:
        if not ok:
            lossy += 1
    out.append(text[pos:m.end()])
    out[-1] = text[pos:m.start()]  # 只保留段前原文
    out.append(best)
    pos = m.end() + take
out.append(text[pos:])
result = ''.join(out)

open(DST, 'wb').write(result.encode('utf-8'))
print('已写出:', DST)
print('有损修复的段数(含无法恢复的字节):', lossy)
print('剩余 ? 个数:', result.count('?'))
