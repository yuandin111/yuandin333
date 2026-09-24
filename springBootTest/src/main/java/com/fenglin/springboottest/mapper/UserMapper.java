package com.fenglin.springboottest.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.fenglin.springboottest.entity.User;

/**
 * 用户 Mapper：继承 BaseMapper 后即拥有单表 CRUD 能力，无需编写 XML。
 */
public interface UserMapper extends BaseMapper<User> {
}
