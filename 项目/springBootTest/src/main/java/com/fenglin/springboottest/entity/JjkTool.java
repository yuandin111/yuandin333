package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 咒具图鉴实体，对应表 jjk_tool
 */
@Data
@TableName("jjk_tool")
public class JjkTool {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 咒具名 */
    private String name;

    /** 图标 emoji */
    private String icon;

    /** 等级文字，如：特级咒具 */
    private String grade;

    /** 等级样式：top / relic / maybe / unknown */
    private String gradeClass;

    /** 持有者 */
    private String owner;

    /** 详细介绍（数据库列 description，前后端 JSON 字段为 desc） */
    @JsonProperty("desc")
    private String description;

    /** 排序，越小越靠前 */
    private Integer sort;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
