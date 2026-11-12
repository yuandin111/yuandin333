package com.fenglin.springboottest.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.fenglin.springboottest.entity.ForumLike;
import org.apache.ibatis.annotations.Mapper;

/** ForumLike Mapper */
@Mapper
public interface ForumLikeMapper extends BaseMapper<ForumLike> {
}
