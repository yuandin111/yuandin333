package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/** 论坛帖子，对应表 forum_post */
@Data
@TableName("forum_post")
public class ForumPost {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String content;
    private String category;
    private String tags;
    private String coverUrl;
    private Long authorId;
    private String authorName;
    private Integer likeCount;
    private Integer commentCount;
    private Integer viewCount;
    private Integer isTop;
    private Integer isEssence;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    /** 非数据库字段：当前登录用户是否已点赞 */
    @TableField(exist = false)
    private Boolean liked;
    /** 非数据库字段：板块中文名 */
    @TableField(exist = false)
    private String categoryName;
}
