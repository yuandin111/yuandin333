-- 置顶：选两篇热度最高的精华帖（幂等，可重复执行）
UPDATE forum_post SET is_top=1, update_time=NOW() WHERE id IN (1, 6);
-- 其余帖子取消置顶，保证同时最多这两篇
UPDATE forum_post SET is_top=0 WHERE id NOT IN (1, 6) AND is_top<>0;

SELECT id, title, is_top, is_essence FROM forum_post WHERE is_top=1;
