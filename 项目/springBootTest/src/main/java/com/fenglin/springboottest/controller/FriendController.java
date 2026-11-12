package com.fenglin.springboottest.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.fenglin.springboottest.common.AuthTokens;
import com.fenglin.springboottest.common.CurrentUser;
import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.entity.FriendMessage;
import com.fenglin.springboottest.entity.FriendRequest;
import com.fenglin.springboottest.entity.Friendship;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.FriendMessageMapper;
import com.fenglin.springboottest.mapper.FriendRequestMapper;
import com.fenglin.springboottest.mapper.FriendshipMapper;
import com.fenglin.springboottest.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 好友功能接口：找人 / 好友申请 / 好友列表 / 私信。
 * 全部接口要求登录（读个人数据、写操作均需 token）。
 */
@RestController
@RequestMapping("/api/friends")
public class FriendController {

    @Autowired
    private UserMapper userMapper;
    @Autowired
    private FriendRequestMapper requestMapper;
    @Autowired
    private FriendshipMapper friendshipMapper;
    @Autowired
    private FriendMessageMapper messageMapper;

    /** 概览：好友数 / 待处理申请数 / 未读私信数，供首页角标使用 */
    @GetMapping("/overview")
    public Result<Map<String, Object>> overview(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = require(authorization);
        if (me == null) {
            return Result.error(401, "请先登录");
        }
        Map<String, Object> data = new HashMap<>();
        data.put("friends", friendshipMapper.selectCount(new LambdaQueryWrapper<Friendship>()
                .eq(Friendship::getUserId, me.userId())));
        data.put("pending", requestMapper.selectCount(new LambdaQueryWrapper<FriendRequest>()
                .eq(FriendRequest::getToUserId, me.userId())
                .eq(FriendRequest::getStatus, 0)));
        data.put("unread", messageMapper.selectCount(new LambdaQueryWrapper<FriendMessage>()
                .eq(FriendMessage::getToUserId, me.userId())
                .eq(FriendMessage::getIsRead, 0)));
        return Result.success(data);
    }

    /**
     * 找人：按用户名模糊搜索，返回 relation 状态
     * none / pending_sent(我发出的待处理) / pending_received(对方发给我的待处理) / friend
     * 只返回 id + 用户名，不暴露密码等字段。
     */
    @GetMapping("/users")
    public Result<List<Map<String, Object>>> users(
            @RequestParam(required = false) String q,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = require(authorization);
        if (me == null) {
            return Result.error(401, "请先登录");
        }
        String kw = q == null ? "" : q.trim();
        LambdaQueryWrapper<User> w = new LambdaQueryWrapper<User>()
                .ne(User::getId, me.userId());
        if (!kw.isEmpty()) {
            w.like(User::getUsername, kw);
        }
        List<User> users = userMapper.selectList(w.orderByAsc(User::getId).last("LIMIT 30"));

        Set<Long> friendIds = friendshipMapper.selectList(new LambdaQueryWrapper<Friendship>()
                        .eq(Friendship::getUserId, me.userId()))
                .stream().map(Friendship::getFriendId).collect(Collectors.toSet());
        Set<Long> sentIds = requestMapper.selectList(new LambdaQueryWrapper<FriendRequest>()
                        .eq(FriendRequest::getFromUserId, me.userId())
                        .eq(FriendRequest::getStatus, 0))
                .stream().map(FriendRequest::getToUserId).collect(Collectors.toSet());
        Set<Long> recvIds = requestMapper.selectList(new LambdaQueryWrapper<FriendRequest>()
                        .eq(FriendRequest::getToUserId, me.userId())
                        .eq(FriendRequest::getStatus, 0))
                .stream().map(FriendRequest::getFromUserId).collect(Collectors.toSet());

        List<Map<String, Object>> list = new ArrayList<>();
        for (User u : users) {
            String relation = "none";
            if (friendIds.contains(u.getId())) relation = "friend";
            else if (sentIds.contains(u.getId())) relation = "pending_sent";
            else if (recvIds.contains(u.getId())) relation = "pending_received";
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id", u.getId());
            row.put("username", u.getUsername());
            row.put("relation", relation);
            list.add(row);
        }
        return Result.success(list);
    }

    /** 好友申请列表：收到的 / 我发出的（只返回待处理） */
    @GetMapping("/requests")
    public Result<Map<String, Object>> requests(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = require(authorization);
        if (me == null) {
            return Result.error(401, "请先登录");
        }
        List<FriendRequest> incoming = requestMapper.selectList(new LambdaQueryWrapper<FriendRequest>()
                .eq(FriendRequest::getToUserId, me.userId())
                .eq(FriendRequest::getStatus, 0)
                .orderByDesc(FriendRequest::getCreateTime));
        List<FriendRequest> outgoing = requestMapper.selectList(new LambdaQueryWrapper<FriendRequest>()
                .eq(FriendRequest::getFromUserId, me.userId())
                .eq(FriendRequest::getStatus, 0)
                .orderByDesc(FriendRequest::getCreateTime));
        Map<String, Object> data = new HashMap<>();
        data.put("incoming", incoming);
        data.put("outgoing", outgoing);
        data.put("pending", incoming.size());
        return Result.success(data);
    }

    /** 发送好友申请：body = {toUserId, message} */
    @PostMapping("/requests")
    public Result<FriendRequest> sendRequest(
            @RequestBody Map<String, Object> body,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = require(authorization);
        if (me == null) {
            return Result.error(401, "请先登录");
        }
        Long toUserId = CurrentUser.toLong(body.get("toUserId"));
        if (toUserId == null) {
            return Result.error(400, "请选择要添加的用户");
        }
        if (Objects.equals(toUserId, me.userId())) {
            return Result.error(400, "不能给自己发好友申请");
        }
        User target = userMapper.selectById(toUserId);
        if (target == null) {
            return Result.error(404, "用户不存在");
        }
        if (isFriend(me.userId(), toUserId)) {
            return Result.error(409, "你们已经是好友了");
        }
        Long exists = requestMapper.selectCount(new LambdaQueryWrapper<FriendRequest>()
                .eq(FriendRequest::getFromUserId, me.userId())
                .eq(FriendRequest::getToUserId, toUserId)
                .eq(FriendRequest::getStatus, 0));
        if (exists != null && exists > 0) {
            return Result.error(409, "申请已发送，请等待对方处理");
        }
        Long reverse = requestMapper.selectCount(new LambdaQueryWrapper<FriendRequest>()
                .eq(FriendRequest::getFromUserId, toUserId)
                .eq(FriendRequest::getToUserId, me.userId())
                .eq(FriendRequest::getStatus, 0));
        if (reverse != null && reverse > 0) {
            return Result.error(409, "对方已向你发送申请，请先在「申请」里处理");
        }

        FriendRequest req = new FriendRequest();
        req.setFromUserId(me.userId());
        req.setFromUserName(me.username());
        req.setToUserId(toUserId);
        req.setToUserName(target.getUsername());
        String msg = str(body.get("message"));
        req.setMessage(msg == null ? "" : msg.trim());
        req.setStatus(0);
        req.setCreateTime(LocalDateTime.now());
        requestMapper.insert(req);
        return Result.success("申请已发送", req);
    }

    /** 同意好友申请 */
    @PostMapping("/requests/{id}/accept")
    public Result<Void> accept(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = require(authorization);
        if (me == null) {
            return Result.error(401, "请先登录");
        }
        FriendRequest req = requestMapper.selectById(id);
        if (req == null || !Objects.equals(req.getToUserId(), me.userId())
                || !Integer.valueOf(0).equals(req.getStatus())) {
            return Result.error(404, "待处理的申请不存在");
        }
        req.setStatus(1);
        req.setHandleTime(LocalDateTime.now());
        requestMapper.updateById(req);
        addFriendship(me.userId(), me.username(), req.getFromUserId(), req.getFromUserName());
        return Result.success("已添加好友", null);
    }

    /** 拒绝好友申请 */
    @PostMapping("/requests/{id}/reject")
    public Result<Void> reject(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = require(authorization);
        if (me == null) {
            return Result.error(401, "请先登录");
        }
        FriendRequest req = requestMapper.selectById(id);
        if (req == null || !Objects.equals(req.getToUserId(), me.userId())
                || !Integer.valueOf(0).equals(req.getStatus())) {
            return Result.error(404, "待处理的申请不存在");
        }
        req.setStatus(2);
        req.setHandleTime(LocalDateTime.now());
        requestMapper.updateById(req);
        return Result.success("已拒绝", null);
    }

    /** 好友列表（带未读数与最后一条私信预览） */
    @GetMapping("/list")
    public Result<List<Map<String, Object>>> list(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = require(authorization);
        if (me == null) {
            return Result.error(401, "请先登录");
        }
        List<Friendship> fs = friendshipMapper.selectList(new LambdaQueryWrapper<Friendship>()
                .eq(Friendship::getUserId, me.userId())
                .orderByAsc(Friendship::getCreateTime));

        List<Map<String, Object>> list = new ArrayList<>();
        for (Friendship f : fs) {
            Long peer = f.getFriendId();
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("friendId", peer);
            row.put("friendName", f.getFriendName());
            row.put("since", f.getCreateTime());
            row.put("unread", messageMapper.selectCount(new LambdaQueryWrapper<FriendMessage>()
                    .eq(FriendMessage::getFromUserId, peer)
                    .eq(FriendMessage::getToUserId, me.userId())
                    .eq(FriendMessage::getIsRead, 0)));
            FriendMessage last = lastMessage(me.userId(), peer);
            row.put("lastMessage", last == null ? "" : last.getContent());
            row.put("lastTime", last == null ? null : last.getCreateTime());
            list.add(row);
        }
        return Result.success(list);
    }

    /** 删除好友（双向解除） */
    @DeleteMapping("/{friendId}")
    public Result<Void> removeFriend(
            @PathVariable Long friendId,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = require(authorization);
        if (me == null) {
            return Result.error(401, "请先登录");
        }
        friendshipMapper.delete(new LambdaQueryWrapper<Friendship>()
                .eq(Friendship::getUserId, me.userId())
                .eq(Friendship::getFriendId, friendId));
        friendshipMapper.delete(new LambdaQueryWrapper<Friendship>()
                .eq(Friendship::getUserId, friendId)
                .eq(Friendship::getFriendId, me.userId()));
        return Result.success("已解除好友关系", null);
    }

    /** 与某好友的私信记录（按时间升序，最多 200 条），拉取后把对方发来的标记已读 */
    @GetMapping("/messages")
    public Result<List<Map<String, Object>>> messages(
            @RequestParam Long peerId,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = require(authorization);
        if (me == null) {
            return Result.error(401, "请先登录");
        }
        if (!isFriend(me.userId(), peerId)) {
            return Result.error(403, "只能查看好友的私信");
        }
        List<FriendMessage> msgs = messageMapper.selectList(pairWrapper(me.userId(), peerId)
                .orderByAsc(FriendMessage::getId).last("LIMIT 200"));

        FriendMessage patch = new FriendMessage();
        patch.setIsRead(1);
        messageMapper.update(patch, new LambdaUpdateWrapper<FriendMessage>()
                .eq(FriendMessage::getFromUserId, peerId)
                .eq(FriendMessage::getToUserId, me.userId())
                .eq(FriendMessage::getIsRead, 0));

        List<Map<String, Object>> list = new ArrayList<>();
        for (FriendMessage m : msgs) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id", m.getId());
            row.put("content", m.getContent());
            row.put("createTime", m.getCreateTime());
            row.put("mine", Objects.equals(m.getFromUserId(), me.userId()));
            list.add(row);
        }
        return Result.success(list);
    }

    /** 发送私信：body = {toUserId, content} */
    @PostMapping("/messages")
    public Result<FriendMessage> sendMessage(
            @RequestBody Map<String, Object> body,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        AuthTokens.Entry me = require(authorization);
        if (me == null) {
            return Result.error(401, "请先登录");
        }
        Long toUserId = CurrentUser.toLong(body.get("toUserId"));
        String content = str(body.get("content"));
        if (toUserId == null || content == null || content.isBlank()) {
            return Result.error(400, "参数不完整");
        }
        if (content.length() > 1000) {
            return Result.error(400, "消息最多 1000 字");
        }
        if (!isFriend(me.userId(), toUserId)) {
            return Result.error(403, "只能给好友发私信");
        }
        FriendMessage msg = new FriendMessage();
        msg.setFromUserId(me.userId());
        msg.setToUserId(toUserId);
        msg.setContent(content.trim());
        msg.setIsRead(0);
        msg.setCreateTime(LocalDateTime.now());
        messageMapper.insert(msg);
        return Result.success("已发送", msg);
    }

    // ==================== 私有工具 ====================

    private AuthTokens.Entry require(String authorization) {
        return CurrentUser.get(authorization);
    }

    private boolean isFriend(Long me, Long peer) {
        Long count = friendshipMapper.selectCount(new LambdaQueryWrapper<Friendship>()
                .eq(Friendship::getUserId, me)
                .eq(Friendship::getFriendId, peer));
        return count != null && count > 0;
    }

    /** 双向各插一条好友关系，已存在则跳过 */
    private void addFriendship(Long me, String meName, Long peer, String peerName) {
        if (!isFriend(me, peer)) {
            Friendship a = new Friendship();
            a.setUserId(me);
            a.setFriendId(peer);
            a.setFriendName(peerName);
            a.setCreateTime(LocalDateTime.now());
            friendshipMapper.insert(a);
        }
        if (!isFriend(peer, me)) {
            Friendship b = new Friendship();
            b.setUserId(peer);
            b.setFriendId(me);
            b.setFriendName(meName);
            b.setCreateTime(LocalDateTime.now());
            friendshipMapper.insert(b);
        }
    }

    /** 两人之间的会话条件（带括号，避免 OR 串到其它条件上） */
    private LambdaQueryWrapper<FriendMessage> pairWrapper(Long me, Long peer) {
        return new LambdaQueryWrapper<FriendMessage>()
                .and(x -> x.eq(FriendMessage::getFromUserId, me).eq(FriendMessage::getToUserId, peer)
                        .or().eq(FriendMessage::getFromUserId, peer).eq(FriendMessage::getToUserId, me));
    }

    private FriendMessage lastMessage(Long me, Long peer) {
        List<FriendMessage> list = messageMapper.selectList(pairWrapper(me, peer)
                .orderByDesc(FriendMessage::getId).last("LIMIT 1"));
        return list.isEmpty() ? null : list.get(0);
    }

    private String str(Object value) {
        return value == null ? null : String.valueOf(value);
    }
}
