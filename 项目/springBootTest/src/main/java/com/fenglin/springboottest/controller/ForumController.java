package com.fenglin.springboottest.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fenglin.springboottest.common.AuthTokens;
import com.fenglin.springboottest.common.CurrentUser;
import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.entity.ForumComment;
import com.fenglin.springboottest.entity.ForumLike;
import com.fenglin.springboottest.entity.ForumPost;
import com.fenglin.springboottest.mapper.ForumCommentMapper;
import com.fenglin.springboottest.mapper.ForumLikeMapper;
import com.fenglin.springboottest.mapper.ForumPostMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 社区论坛接口：板块 / 帖子 / 评论 / 点赞。
 * 读接口公开，写接口要求携带登录 token；作者本人或管理员可编辑、删除。
 */
@RestController
@RequestMapping("/api/forum")
public class ForumController {

    /** 板块定义：key / 中文名 / 图标 */
    private static final String[][] CATEGORIES = {
            {"all", "全部", "✦"},
            {"fanwork", "同人二创", "✍️"},
            {"fanart", "同人图绘", "🎨"},
            {"discuss", "剧情讨论", "💬"},
            {"lore", "术式考据", "📜"},
            {"chat", "闲聊水区", "🍵"}
    };

    @Autowired
    private ForumPostMapper postMapper;
    @Autowired
    private ForumCommentMapper commentMapper;
    @Autowired
    private ForumLikeMapper likeMapper;

    /** 板块列表（含每个板块的帖子数，用于前端 tab 角标） */
    @GetMapping("/categories")
    public Result<List<Map<String, Object>>> categories() {
        List<Map<String, Object>> list = new ArrayList<>();
        for (String[] c : CATEGORIES) {
            LambdaQueryWrapper<ForumPost> w = new LambdaQueryWrapper<ForumPost>()
                    .eq(ForumPost::getStatus, 1);
            if (!"all".equals(c[0])) {
                w.eq(ForumPost::getCategory, c[0]);
            }
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("key", c[0]);
            m.put("name", c[1]);
            m.put("icon", c[2]);
            m.put("count", postMapper.selectCount(w));
            list.add(m);
        }
        return Result.success(list);
    }

    /**
     * 帖子列表：支持板块筛选、关键词搜索、最新/热门排序、分页。
     * 已登录时会额外返回当前用户是否已点赞（liked）。
     */
    @GetMapping("/posts")
    public Result<Map<String, Object>> posts(
            @RequestParam(defaultValue = "all") String category,
            @RequestParam(required = false) String q,
            @RequestParam(defaultValue = "new") String sort,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "8") int size,
            @RequestHeader(value = "Authorization", required = false) String authorization) {

        int safePage = Math.max(1, page);
        int safeSize = Math.min(20, Math.max(1, size));
        int offset = (safePage - 1) * safeSize;

        LambdaQueryWrapper<ForumPost> w = new LambdaQueryWrapper<ForumPost>()
                .eq(ForumPost::getStatus, 1);
        if (category != null && !category.isBlank() && !"all".equals(category)) {
            w.eq(ForumPost::getCategory, category.trim());
        }
        if (q != null && !q.trim().isEmpty()) {
            String kw = q.trim();
            w.and(x -> x.like(ForumPost::getTitle, kw)
                    .or().like(ForumPost::getContent, kw)
                    .or().like(ForumPost::getTags, kw)
                    .or().like(ForumPost::getAuthorName, kw));
        }

        Long total = postMapper.selectCount(w);
        if ("hot".equals(sort)) {
            w.orderByDesc(ForumPost::getIsTop)
                    .orderByDesc(ForumPost::getLikeCount)
                    .orderByDesc(ForumPost::getCreateTime);
        } else {
            w.orderByDesc(ForumPost::getIsTop)
                    .orderByDesc(ForumPost::getCreateTime);
        }
        List<ForumPost> records = postMapper.selectList(w.last("LIMIT " + offset + "," + safeSize));

        AuthTokens.Entry me = CurrentUser.get(authorization);
        decorate(records, me == null ? null : me.userId());

        Map<String, Object> data = new HashMap<>();
        data.put("list", records);
        data.put("total", total);
        data.put("page", safePage);
        data.put("size", safeSize);
        data.put("hasMore", (long) offset + records.size() < total);
        return Result.success(data);
    }

    /** 帖子详情（浏览量 +1），已登录时返回点赞状态 */
    @GetMapping("/posts/{id}")
    public Result<ForumPost> detail(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        ForumPost post = postMapper.selectById(id);
        if (post == null || !Integer.valueOf(1).equals(post.getStatus())) {
            return Result.error(404, "帖子不存在或已删除");
        }
        post.setViewCount((post.getViewCount() == null ? 0 : post.getViewCount()) + 1);
        postMapper.updateById(post);

        AuthTokens.Entry me = CurrentUser.get(authorization);
        decorate(List.of(post), me == null ? null : me.userId());
        return Result.success(post);
    }

    /** 发帖 */
    @PostMapping("/posts")
    public Result<ForumPost> create(
            @RequestBody Map<String, Object> body,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = CurrentUser.get(authorization);
        if (me == null) {
            return Result.error(401, "请先登录后再发帖");
        }
        String title = str(body.get("title"));
        String content = str(body.get("content"));
        if (title == null || title.isBlank() || content == null || content.isBlank()) {
            return Result.error(400, "标题和正文不能为空");
        }
        if (title.length() > 120) {
            return Result.error(400, "标题最多 120 字");
        }
        if (content.length() > 20000) {
            return Result.error(400, "正文过长");
        }
        String category = validCategory(str(body.get("category")));

        ForumPost post = new ForumPost();
        post.setTitle(title.trim());
        post.setContent(content.trim());
        post.setCategory(category);
        post.setTags(str(body.get("tags")));
        post.setCoverUrl(str(body.get("coverUrl")));
        post.setAuthorId(me.userId());
        post.setAuthorName(me.username());
        post.setLikeCount(0);
        post.setCommentCount(0);
        post.setViewCount(0);
        post.setIsTop(0);
        post.setIsEssence(0);
        post.setStatus(1);
        post.setCreateTime(LocalDateTime.now());
        post.setUpdateTime(LocalDateTime.now());
        postMapper.insert(post);
        post.setLiked(false);
        post.setCategoryName(nameOf(category));
        return Result.success("发帖成功", post);
    }

    /** 编辑自己的帖子（管理员也可编辑） */
    @PutMapping("/posts/{id}")
    public Result<ForumPost> update(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = CurrentUser.get(authorization);
        if (me == null) {
            return Result.error(401, "请先登录");
        }
        ForumPost post = postMapper.selectById(id);
        if (post == null || !Integer.valueOf(1).equals(post.getStatus())) {
            return Result.error(404, "帖子不存在");
        }
        if (!canManage(me, post)) {
            return Result.error(403, "只能编辑自己的帖子");
        }
        String title = str(body.get("title"));
        String content = str(body.get("content"));
        if (title == null || title.isBlank() || content == null || content.isBlank()) {
            return Result.error(400, "标题和正文不能为空");
        }
        post.setTitle(title.trim());
        post.setContent(content.trim());
        post.setCategory(validCategory(str(body.get("category"))));
        post.setTags(str(body.get("tags")));
        post.setCoverUrl(str(body.get("coverUrl")));
        post.setUpdateTime(LocalDateTime.now());
        postMapper.updateById(post);
        decorate(List.of(post), me.userId());
        return Result.success("修改成功", post);
    }

    /** 删除帖子（逻辑删除） */
    @DeleteMapping("/posts/{id}")
    public Result<Void> remove(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = CurrentUser.get(authorization);
        if (me == null) {
            return Result.error(401, "请先登录");
        }
        ForumPost post = postMapper.selectById(id);
        if (post == null) {
            return Result.error(404, "帖子不存在");
        }
        if (!canManage(me, post)) {
            return Result.error(403, "只能删除自己的帖子");
        }
        post.setStatus(0);
        post.setUpdateTime(LocalDateTime.now());
        postMapper.updateById(post);
        return Result.success("已删除", null);
    }

    /** 点赞 / 取消点赞（toggle） */
    @PostMapping("/posts/{id}/like")
    public Result<Map<String, Object>> toggleLike(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = CurrentUser.get(authorization);
        if (me == null) {
            return Result.error(401, "请先登录后再点赞");
        }
        ForumPost post = postMapper.selectById(id);
        if (post == null || !Integer.valueOf(1).equals(post.getStatus())) {
            return Result.error(404, "帖子不存在");
        }
        ForumLike existing = likeMapper.selectOne(new LambdaQueryWrapper<ForumLike>()
                .eq(ForumLike::getPostId, id)
                .eq(ForumLike::getUserId, me.userId())
                .last("LIMIT 1"));

        boolean liked;
        int count = post.getLikeCount() == null ? 0 : post.getLikeCount();
        if (existing == null) {
            ForumLike like = new ForumLike();
            like.setPostId(id);
            like.setUserId(me.userId());
            like.setCreateTime(LocalDateTime.now());
            likeMapper.insert(like);
            count++;
            liked = true;
        } else {
            likeMapper.deleteById(existing.getId());
            count = Math.max(0, count - 1);
            liked = false;
        }
        post.setLikeCount(count);
        postMapper.updateById(post);

        Map<String, Object> data = new HashMap<>();
        data.put("liked", liked);
        data.put("likeCount", count);
        return Result.success(liked ? "已点赞" : "已取消点赞", data);
    }

    /** 帖子的评论列表（含楼中楼回复，按时间升序） */
    @GetMapping("/posts/{id}/comments")
    public Result<List<ForumComment>> comments(@PathVariable Long id) {
        return Result.success(commentMapper.selectList(new LambdaQueryWrapper<ForumComment>()
                .eq(ForumComment::getPostId, id)
                .eq(ForumComment::getStatus, 1)
                .orderByAsc(ForumComment::getCreateTime)
                .orderByAsc(ForumComment::getId)));
    }

    /** 发表评论或回复：body = {content, parentId?, replyToName?} */
    @PostMapping("/posts/{id}/comments")
    public Result<ForumComment> addComment(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = CurrentUser.get(authorization);
        if (me == null) {
            return Result.error(401, "请先登录后再评论");
        }
        ForumPost post = postMapper.selectById(id);
        if (post == null || !Integer.valueOf(1).equals(post.getStatus())) {
            return Result.error(404, "帖子不存在");
        }
        String content = str(body.get("content"));
        if (content == null || content.isBlank()) {
            return Result.error(400, "评论内容不能为空");
        }
        if (content.length() > 1000) {
            return Result.error(400, "评论最多 1000 字");
        }

        ForumComment comment = new ForumComment();
        comment.setPostId(id);
        comment.setParentId(CurrentUser.toLong(body.get("parentId")));
        comment.setReplyToName(str(body.get("replyToName")));
        comment.setUserId(me.userId());
        comment.setUserName(me.username());
        comment.setContent(content.trim());
        comment.setLikeCount(0);
        comment.setStatus(1);
        comment.setCreateTime(LocalDateTime.now());
        commentMapper.insert(comment);

        post.setCommentCount((post.getCommentCount() == null ? 0 : post.getCommentCount()) + 1);
        postMapper.updateById(post);
        return Result.success("评论成功", comment);
    }

    /** 删除自己的评论（管理员也可删除） */
    @DeleteMapping("/comments/{id}")
    public Result<Void> removeComment(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = CurrentUser.get(authorization);
        if (me == null) {
            return Result.error(401, "请先登录");
        }
        ForumComment comment = commentMapper.selectById(id);
        if (comment == null) {
            return Result.error(404, "评论不存在");
        }
        boolean own = Objects.equals(me.userId(), comment.getUserId());
        boolean admin = me.permission() != null && me.permission() == 0;
        if (!own && !admin) {
            return Result.error(403, "只能删除自己的评论");
        }
        comment.setStatus(0);
        commentMapper.updateById(comment);

        ForumPost post = postMapper.selectById(comment.getPostId());
        if (post != null && post.getCommentCount() != null && post.getCommentCount() > 0) {
            post.setCommentCount(post.getCommentCount() - 1);
            postMapper.updateById(post);
        }
        return Result.success("已删除", null);
    }

    // ==================== 私有工具 ====================

    /** 补齐列表里的 liked / categoryName 两个非数据库字段 */
    private void decorate(List<ForumPost> list, Long myId) {
        Set<Long> likedIds = Set.of();
        if (myId != null && !list.isEmpty()) {
            List<Long> ids = list.stream().map(ForumPost::getId).collect(Collectors.toList());
            likedIds = likeMapper.selectList(new LambdaQueryWrapper<ForumLike>()
                            .eq(ForumLike::getUserId, myId)
                            .in(ForumLike::getPostId, ids))
                    .stream().map(ForumLike::getPostId).collect(Collectors.toSet());
        }
        for (ForumPost p : list) {
            p.setLiked(likedIds.contains(p.getId()));
            p.setCategoryName(nameOf(p.getCategory()));
        }
    }

    private String nameOf(String key) {
        for (String[] c : CATEGORIES) {
            if (c[0].equals(key)) {
                return c[1];
            }
        }
        return "其他";
    }

    private String validCategory(String key) {
        for (String[] c : CATEGORIES) {
            if (c[0].equals(key) && !"all".equals(key)) {
                return key;
            }
        }
        return "fanwork";
    }

    private boolean canManage(AuthTokens.Entry me, ForumPost post) {
        boolean own = Objects.equals(me.userId(), post.getAuthorId());
        boolean admin = me.permission() != null && me.permission() == 0;
        return own || admin;
    }

    private String str(Object value) {
        return value == null ? null : String.valueOf(value);
    }
}
