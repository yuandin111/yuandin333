package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 人物志实体，对应表 jjk_character
 */
@Data
@TableName("jjk_character")
public class JjkCharacter {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 人物名 */
    private String name;

    /** 图标 emoji */
    private String icon;

    /** 身份/称号 */
    private String role;

    /** 阵营：school 高专 / curse 咒灵·诅咒师 */
    private String camp;

    /** 术式/能力 */
    private String ability;

    /** 关键词，英文逗号分隔 */
    private String tags;

    /** 详细介绍（数据库列 description，前后端 JSON 字段为 desc） */
    @JsonProperty("desc")
    private String description;

    /** 排序，越小越靠前 */
    private Integer sort;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
