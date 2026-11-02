package com.fenglin.springboottest.common;

import lombok.Data;

/**
 * 站内统一检索结果条目（人物 / 咒具 / 事件 三表检索的公共返回结构）
 */
@Data
public class SearchItem {

    /** 类别：character / tool / event */
    private String kind;

    /** 原始记录 id，前端据此定位并打开详情 */
    private Long id;

    /** 名称：人物名 / 咒具名 / 事件标题 */
    private String name;

    /** 副标题：身份 / 等级 / 时代 */
    private String subtitle;

    /** 简介（截断后） */
    private String desc;

    /** 类别显示名：人物 / 咒具 / 事件 */
    private String kindLabel;

    public SearchItem() {
    }

    public SearchItem(String kind, Long id, String name, String subtitle, String desc) {
        this.kind = kind;
        this.id = id;
        this.name = name;
        this.subtitle = subtitle;
        this.desc = desc;
        this.kindLabel = "character".equals(kind) ? "人物" : "tool".equals(kind) ? "咒具" : "事件";
    }
}
