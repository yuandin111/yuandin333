package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 时间线事件实体，对应表 jjk_event
 */
@Data
@TableName("jjk_event")
public class JjkEvent {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 时代/时间 */
    private String era;

    /** 事件标题 */
    private String title;

    /** 详细介绍（数据库列 description，前后端 JSON 字段为 desc） */
    @JsonProperty("desc")
    private String description;

    /** 排序，越小越靠前 */
    private Integer sort;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
