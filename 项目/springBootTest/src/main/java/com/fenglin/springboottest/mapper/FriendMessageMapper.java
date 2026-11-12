package com.fenglin.springboottest.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.fenglin.springboottest.entity.FriendMessage;
import org.apache.ibatis.annotations.Mapper;

/** FriendMessage Mapper */
@Mapper
public interface FriendMessageMapper extends BaseMapper<FriendMessage> {
}
