package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/** 论坛评论/回复，对应表 forum_comment */
@Data
@TableName("forum_comment")
public class ForumComment {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long postId;
    private Long parentId;
    private String replyToName;
    private Long userId;
    private String userName;
    private String content;
    private Integer likeCount;
    private Integer status;
    private LocalDateTime createTime;
}
