package com.fenglin.springboottest.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.entity.ForumPost;
import com.fenglin.springboottest.entity.JjkCharacter;
import com.fenglin.springboottest.entity.JjkEvent;
import com.fenglin.springboottest.entity.JjkTool;
import com.fenglin.springboottest.mapper.ForumPostMapper;
import com.fenglin.springboottest.mapper.JjkCharacterMapper;
import com.fenglin.springboottest.mapper.JjkEventMapper;
import com.fenglin.springboottest.mapper.JjkToolMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 后台管理接口：人物志 / 咒具图鉴 / 时间线 / 论坛帖子 的增删改查。
 * 全部路径在 /api/admin/** 下，由 AdminAuthInterceptor 统一做管理员鉴权。
 */
@RestController
@RequestMapping("/api/admin")
public class AdminContentController {

    @Autowired
    private JjkCharacterMapper characterMapper;
    @Autowired
    private JjkToolMapper toolMapper;
    @Autowired
    private JjkEventMapper eventMapper;
    @Autowired
    private ForumPostMapper postMapper;

    // ==================== 人物志 ====================

    @GetMapping("/characters")
    public Result<List<JjkCharacter>> listCharacters() {
        return Result.success(characterMapper.selectList(
                new LambdaQueryWrapper<JjkCharacter>().orderByAsc(JjkCharacter::getSort)));
    }

    @PostMapping("/characters")
    public Result<JjkCharacter> createCharacter(@RequestBody JjkCharacter c) {
        if (c.getName() == null || c.getName().isBlank()) {
            return Result.error(400, "人物名不能为空");
        }
        c.setId(null);
        if (c.getSort() == null) {
            c.setSort(0);
        }
        c.setCreateTime(LocalDateTime.now());
        c.setUpdateTime(LocalDateTime.now());
        characterMapper.insert(c);
        return Result.success("新增成功", c);
    }

    @PutMapping("/characters/{id}")
    public Result<JjkCharacter> updateCharacter(@PathVariable Long id, @RequestBody JjkCharacter c) {
        if (characterMapper.selectById(id) == null) {
            return Result.error(404, "记录不存在");
        }
        c.setId(id);
        c.setUpdateTime(LocalDateTime.now());
        characterMapper.updateById(c);
        return Result.success("修改成功", characterMapper.selectById(id));
    }

    @DeleteMapping("/characters/{id}")
    public Result<Void> deleteCharacter(@PathVariable Long id) {
        if (characterMapper.deleteById(id) == 0) {
            return Result.error(404, "记录不存在");
        }
        return Result.success("删除成功", null);
    }

    // ==================== 咒具图鉴 ====================

    @GetMapping("/tools")
    public Result<List<JjkTool>> listTools() {
        return Result.success(toolMapper.selectList(
                new LambdaQueryWrapper<JjkTool>().orderByAsc(JjkTool::getSort)));
    }

    @PostMapping("/tools")
    public Result<JjkTool> createTool(@RequestBody JjkTool t) {
        if (t.getName() == null || t.getName().isBlank()) {
            return Result.error(400, "咒具名不能为空");
        }
        t.setId(null);
        if (t.getSort() == null) {
            t.setSort(0);
        }
        t.setCreateTime(LocalDateTime.now());
        t.setUpdateTime(LocalDateTime.now());
        toolMapper.insert(t);
        return Result.success("新增成功", t);
    }

    @PutMapping("/tools/{id}")
    public Result<JjkTool> updateTool(@PathVariable Long id, @RequestBody JjkTool t) {
        if (toolMapper.selectById(id) == null) {
            return Result.error(404, "记录不存在");
        }
        t.setId(id);
        t.setUpdateTime(LocalDateTime.now());
        toolMapper.updateById(t);
        return Result.success("修改成功", toolMapper.selectById(id));
    }

    @DeleteMapping("/tools/{id}")
    public Result<Void> deleteTool(@PathVariable Long id) {
        if (toolMapper.deleteById(id) == 0) {
            return Result.error(404, "记录不存在");
        }
        return Result.success("删除成功", null);
    }

    // ==================== 时间线 ====================

    @GetMapping("/events")
    public Result<List<JjkEvent>> listEvents() {
        return Result.success(eventMapper.selectList(
                new LambdaQueryWrapper<JjkEvent>().orderByAsc(JjkEvent::getSort)));
    }

    @PostMapping("/events")
    public Result<JjkEvent> createEvent(@RequestBody JjkEvent e) {
        if (e.getTitle() == null || e.getTitle().isBlank() || e.getEra() == null || e.getEra().isBlank()) {
            return Result.error(400, "时代和标题不能为空");
        }
        e.setId(null);
        if (e.getSort() == null) {
            e.setSort(0);
        }
        e.setCreateTime(LocalDateTime.now());
        e.setUpdateTime(LocalDateTime.now());
        eventMapper.insert(e);
        return Result.success("新增成功", e);
    }

    @PutMapping("/events/{id}")
    public Result<JjkEvent> updateEvent(@PathVariable Long id, @RequestBody JjkEvent e) {
        if (eventMapper.selectById(id) == null) {
            return Result.error(404, "记录不存在");
        }
        e.setId(id);
        e.setUpdateTime(LocalDateTime.now());
        eventMapper.updateById(e);
        return Result.success("修改成功", eventMapper.selectById(id));
    }

    @DeleteMapping("/events/{id}")
    public Result<Void> deleteEvent(@PathVariable Long id) {
        if (eventMapper.deleteById(id) == 0) {
            return Result.error(404, "记录不存在");
        }
        return Result.success("删除成功", null);
    }

    // ==================== 论坛帖子 ====================

    /** 板块 key -> 中文名（用于后台列表展示，与前台 ForumController 保持一致） */
    private static final Map<String, String> CATEGORY_NAMES = new LinkedHashMap<>();
    static {
        CATEGORY_NAMES.put("fanwork", "同人二创");
        CATEGORY_NAMES.put("fanart", "同人图绘");
        CATEGORY_NAMES.put("discuss", "剧情讨论");
        CATEGORY_NAMES.put("lore", "术式考据");
        CATEGORY_NAMES.put("chat", "闲聊水区");
    }

    /** 后台帖子列表：按创建时间倒序，支持按板块/关键词过滤 */
    @GetMapping("/posts")
    public Result<List<ForumPost>> listPosts(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String q) {
        LambdaQueryWrapper<ForumPost> w = new LambdaQueryWrapper<>();
        if (category != null && !category.isBlank() && !"all".equals(category)) {
            w.eq(ForumPost::getCategory, category);
        }
        if (q != null && !q.isBlank()) {
            w.and(wrapper -> wrapper.like(ForumPost::getTitle, q)
                    .or().like(ForumPost::getContent, q)
                    .or().like(ForumPost::getAuthorName, q));
        }
        w.orderByDesc(ForumPost::getCreateTime);
        List<ForumPost> list = postMapper.selectList(w);
        for (ForumPost p : list) {
            p.setCategoryName(CATEGORY_NAMES.getOrDefault(p.getCategory(), p.getCategory()));
        }
        return Result.success(list);
    }

    /** 后台新增帖子（作者固定为 admin，互动计数从 0 开始） */
    @PostMapping("/posts")
    public Result<ForumPost> createPost(@RequestBody ForumPost body) {
        if (body.getTitle() == null || body.getTitle().isBlank()) {
            return Result.error(400, "标题不能为空");
        }
        body.setId(null);
        body.setAuthorId(1L);
        if (body.getAuthorName() == null || body.getAuthorName().isBlank()) {
            body.setAuthorName("admin");
        }
        body.setLikeCount(0);
        body.setCommentCount(0);
        body.setViewCount(0);
        if (body.getStatus() == null) body.setStatus(1);
        if (body.getIsTop() == null) body.setIsTop(0);
        if (body.getIsEssence() == null) body.setIsEssence(0);
        LocalDateTime now = LocalDateTime.now();
        body.setCreateTime(now);
        body.setUpdateTime(now);
        postMapper.insert(body);
        return Result.success("新增成功", body);
    }

    /** 后台编辑帖子（仅修改可编辑字段，互动计数等由前台维护） */
    @PutMapping("/posts/{id}")
    public Result<ForumPost> updatePost(@PathVariable Long id, @RequestBody ForumPost body) {
        ForumPost exist = postMapper.selectById(id);
        if (exist == null) {
            return Result.error(404, "记录不存在");
        }
        if (body.getTitle() == null || body.getTitle().isBlank()) {
            return Result.error(400, "标题不能为空");
        }
        exist.setTitle(body.getTitle());
        exist.setContent(body.getContent());
        exist.setCategory(body.getCategory());
        exist.setTags(body.getTags());
        if (body.getAuthorName() != null && !body.getAuthorName().isBlank()) {
            exist.setAuthorName(body.getAuthorName());
        }
        if (body.getIsTop() != null) exist.setIsTop(body.getIsTop());
        if (body.getIsEssence() != null) exist.setIsEssence(body.getIsEssence());
        if (body.getStatus() != null) exist.setStatus(body.getStatus());
        exist.setUpdateTime(LocalDateTime.now());
        postMapper.updateById(exist);
        return Result.success("修改成功", exist);
    }

    /** 后台删除帖子（逻辑删除：置 status=0，前台列表自动不再显示） */
    @DeleteMapping("/posts/{id}")
    public Result<Void> deletePost(@PathVariable Long id) {
        ForumPost exist = postMapper.selectById(id);
        if (exist == null) {
            return Result.error(404, "记录不存在");
        }
        exist.setStatus(0);
        exist.setUpdateTime(LocalDateTime.now());
        postMapper.updateById(exist);
        return Result.success("删除成功", null);
    }
}
