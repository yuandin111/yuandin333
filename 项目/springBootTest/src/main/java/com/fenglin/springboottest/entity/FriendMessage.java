package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/** 好友私信，对应表 friend_message */
@Data
@TableName("friend_message")
public class FriendMessage {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long fromUserId;
    private Long toUserId;
    private String content;
    /** 0 未读 / 1 已读 */
    private Integer isRead;
    private LocalDateTime createTime;
}
