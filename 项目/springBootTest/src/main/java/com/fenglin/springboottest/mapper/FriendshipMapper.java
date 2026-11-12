package com.fenglin.springboottest.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.fenglin.springboottest.entity.Friendship;
import org.apache.ibatis.annotations.Mapper;

/** Friendship Mapper */
@Mapper
public interface FriendshipMapper extends BaseMapper<Friendship> {
}
