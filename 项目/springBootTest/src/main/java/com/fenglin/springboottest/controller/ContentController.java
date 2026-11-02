package com.fenglin.springboottest.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.common.SearchItem;
import com.fenglin.springboottest.entity.JjkCharacter;
import com.fenglin.springboottest.entity.JjkEvent;
import com.fenglin.springboottest.entity.JjkTool;
import com.fenglin.springboottest.mapper.JjkCharacterMapper;
import com.fenglin.springboottest.mapper.JjkEventMapper;
import com.fenglin.springboottest.mapper.JjkToolMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

/**
 * 首页内容公开查询接口（无需登录，只读）
 * 2026-11-02 新增：/api/search 站内检索 + 各列表可选筛选参数
 */
@RestController
@RequestMapping("/api")
public class ContentController {

    /** 每类内容检索最多返回条数 */
    private static final int SEARCH_LIMIT_PER_KIND = 8;
    /** 简介截断长度 */
    private static final int DESC_MAX = 80;

    @Autowired
    private JjkCharacterMapper characterMapper;
    @Autowired
    private JjkToolMapper toolMapper;
    @Autowired
    private JjkEventMapper eventMapper;

    /** 人物志列表（可选按阵营筛选：school 高专 / curse 咒灵·诅咒师） */
    @GetMapping("/characters")
    public Result<List<JjkCharacter>> characters(@RequestParam(required = false) String camp) {
        LambdaQueryWrapper<JjkCharacter> w = new LambdaQueryWrapper<JjkCharacter>()
                .orderByAsc(JjkCharacter::getSort);
        if (camp != null && !camp.isBlank()) {
            w.eq(JjkCharacter::getCamp, camp);
        }
        return Result.success(characterMapper.selectList(w));
    }

    /** 咒具图鉴列表（可选按等级样式筛选：top / relic / maybe / unknown） */
    @GetMapping("/tools")
    public Result<List<JjkTool>> tools(@RequestParam(required = false) String gradeClass) {
        LambdaQueryWrapper<JjkTool> w = new LambdaQueryWrapper<JjkTool>()
                .orderByAsc(JjkTool::getSort);
        if (gradeClass != null && !gradeClass.isBlank()) {
            w.eq(JjkTool::getGradeClass, gradeClass);
        }
        return Result.success(toolMapper.selectList(w));
    }

    /** 时间线事件列表（可选按时代文字筛选，如：2018年） */
    @GetMapping("/events")
    public Result<List<JjkEvent>> events(@RequestParam(required = false) String era) {
        LambdaQueryWrapper<JjkEvent> w = new LambdaQueryWrapper<JjkEvent>()
                .orderByAsc(JjkEvent::getSort);
        if (era != null && !era.isBlank()) {
            w.eq(JjkEvent::getEra, era);
        }
        return Result.success(eventMapper.selectList(w));
    }

    /**
     * 站内检索：跨人物 / 咒具 / 事件三表 LIKE 匹配，返回统一结构。
     * 匹配范围：人物(名字/身份/能力/关键词/简介)、咒具(名字/等级/持有者/简介)、事件(时代/标题/简介)
     */
    @GetMapping("/search")
    public Result<List<SearchItem>> search(@RequestParam(required = false) String q) {
        String kw = q == null ? "" : q.trim();
        List<SearchItem> items = new ArrayList<>();
        if (kw.isEmpty()) {
            return Result.success(items);
        }

        // ===== 人物 =====
        characterMapper.selectList(new LambdaQueryWrapper<JjkCharacter>()
                        .like(JjkCharacter::getName, kw)
                        .or().like(JjkCharacter::getRole, kw)
                        .or().like(JjkCharacter::getAbility, kw)
                        .or().like(JjkCharacter::getTags, kw)
                        .or().like(JjkCharacter::getDescription, kw)
                        .orderByAsc(JjkCharacter::getSort)
                        .last("LIMIT " + SEARCH_LIMIT_PER_KIND))
                .forEach(c -> items.add(new SearchItem("character", c.getId(), c.getName(),
                        c.getRole(), cut(c.getDescription()))));

        // ===== 咒具 =====
        toolMapper.selectList(new LambdaQueryWrapper<JjkTool>()
                        .like(JjkTool::getName, kw)
                        .or().like(JjkTool::getGrade, kw)
                        .or().like(JjkTool::getOwner, kw)
                        .or().like(JjkTool::getDescription, kw)
                        .orderByAsc(JjkTool::getSort)
                        .last("LIMIT " + SEARCH_LIMIT_PER_KIND))
                .forEach(t -> items.add(new SearchItem("tool", t.getId(), t.getName(),
                        t.getGrade(), cut(t.getDescription()))));

        // ===== 事件 =====
        eventMapper.selectList(new LambdaQueryWrapper<JjkEvent>()
                        .like(JjkEvent::getEra, kw)
                        .or().like(JjkEvent::getTitle, kw)
                        .or().like(JjkEvent::getDescription, kw)
                        .orderByAsc(JjkEvent::getSort)
                        .last("LIMIT " + SEARCH_LIMIT_PER_KIND))
                .forEach(e -> items.add(new SearchItem("event", e.getId(), e.getTitle(),
                        e.getEra(), cut(e.getDescription()))));

        return Result.success(items);
    }

    /** 简介截断，避免检索结果过长 */
    private String cut(String desc) {
        if (desc == null) {
            return "";
        }
        return desc.length() > DESC_MAX ? desc.substring(0, DESC_MAX) + "…" : desc;
    }
}
