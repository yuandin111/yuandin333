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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 首页内容公开查询接口（无需登录，只读）
 */
@RestController
@RequestMapping("/api")
public class ContentController {

    @Autowired
    private JjkCharacterMapper characterMapper;
    @Autowired
    private JjkToolMapper toolMapper;
    @Autowired
    private JjkEventMapper eventMapper;

    /** 人物志列表 */
    @GetMapping("/characters")
    public Result<List<JjkCharacter>> characters() {
        return Result.success(characterMapper.selectList(
                new LambdaQueryWrapper<JjkCharacter>().orderByAsc(JjkCharacter::getSort)));
    }

    /** 咒具图鉴列表 */
    @GetMapping("/tools")
    public Result<List<JjkTool>> tools() {
        return Result.success(toolMapper.selectList(
                new LambdaQueryWrapper<JjkTool>().orderByAsc(JjkTool::getSort)));
    }

    /** 时间线事件列表 */
    @GetMapping("/events")
    public Result<List<JjkEvent>> events() {
        return Result.success(eventMapper.selectList(
                new LambdaQueryWrapper<JjkEvent>().orderByAsc(JjkEvent::getSort)));
    }
}
