package com.fenglin.springboottest.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.entity.JjkCharacter;
import com.fenglin.springboottest.entity.JjkEvent;
import com.fenglin.springboottest.entity.JjkTool;
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
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 后台管理接口：人物志 / 咒具图鉴 / 时间线 的增删改查。
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
}
