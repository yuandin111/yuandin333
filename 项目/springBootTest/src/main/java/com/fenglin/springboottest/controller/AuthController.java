package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.imageio.ImageIO;
import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 认证接口：登录 / 注册 / 图形验证码，供 Vue 前端调用
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserService userService;

    /** 图形验证码字符池（去掉易混淆的 0/O/1/I/L） */
    private static final char[] CAPTCHA_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".toCharArray();
    private static final int CAPTCHA_LEN = 4;

    /** 验证码内存存储：captchaId -> {验证码文本, 生成时间戳}。生产环境建议换 Redis */
    private static final Map<String, String[]> CAPTCHA_STORE = new ConcurrentHashMap<>();
    private static final long CAPTCHA_EXPIRE_MS = 5 * 60 * 1000L; // 验证码 5 分钟内有效
    private static final int CAPTCHA_W = 120;
    private static final int CAPTCHA_H = 40;
    private static final Random RANDOM = new Random();

    /**
     * 登录
     * 请求体：{"username": "xxx", "password": "xxx"}
     */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");
        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            return Result.error(400, "用户名和密码不能为空");
        }

        User user = userService.login(username.trim(), password);
        if (user == null) {
            return Result.error(401, "用户名或密码错误");
        }

        Map<String, Object> data = new HashMap<>();
        data.put("token", UUID.randomUUID().toString().replace("-", ""));
        data.put("user", user);
        return Result.success("登录成功", data);
    }

    /**
     * 获取图形验证码（图片）
     * 返回：{"captchaId": "xxx", "image": "data:image/png;base64,..."}
     * 前端把 image 直接塞进 <img src> 即可显示，点击图片重新请求本接口即刷新
     */
    @GetMapping("/captcha")
    public Result<Map<String, String>> captcha() {
        purgeExpired();

        StringBuilder text = new StringBuilder();
        for (int i = 0; i < CAPTCHA_LEN; i++) {
            text.append(CAPTCHA_CHARS[RANDOM.nextInt(CAPTCHA_CHARS.length)]);
        }
        String captchaId = UUID.randomUUID().toString().replace("-", "");
        CAPTCHA_STORE.put(captchaId, new String[]{text.toString(), String.valueOf(System.currentTimeMillis())});

        Map<String, String> data = new HashMap<>();
        data.put("captchaId", captchaId);
        data.put("image", "data:image/png;base64," + renderCaptchaImage(text.toString()));
        return Result.success("ok", data);
    }

    /**
     * 注册（用户名 + 图形验证码 + 密码 + 确认密码，不再收集邮箱）
     * 请求体：{"username": "xxx", "captchaId": "xxx", "code": "A7K2", "password": "xxx"}
     */
    @PostMapping("/register")
    public Result<Map<String, Object>> register(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String captchaId = body.get("captchaId");
        String code = body.get("code");
        String password = body.get("password");
        if (username == null || username.isBlank()
                || captchaId == null || captchaId.isBlank()
                || code == null || code.isBlank()
                || password == null || password.length() < 6) {
            return Result.error(400, "参数不完整或密码不足 6 位");
        }
        username = username.trim();
        captchaId = captchaId.trim();
        code = code.trim();

        // 校验图形验证码：存在、未过期、匹配（忽略大小写，一次性使用）
        String[] cached = CAPTCHA_STORE.get(captchaId);
        if (cached == null || System.currentTimeMillis() - Long.parseLong(cached[1]) > CAPTCHA_EXPIRE_MS) {
            CAPTCHA_STORE.remove(captchaId);
            return Result.error(401, "验证码已失效，请点击图片刷新");
        }
        if (!cached[0].equalsIgnoreCase(code)) {
            CAPTCHA_STORE.remove(captchaId); // 无论对错都作废，防止暴力尝试
            return Result.error(401, "验证码错误");
        }
        CAPTCHA_STORE.remove(captchaId);

        User user;
        try {
            // 注册页不再收集邮箱，传 null（UserServiceImpl 已兼容为空）
            user = userService.register(username, null, password);
        } catch (IllegalArgumentException e) {
            return Result.error(409, e.getMessage());
        }

        Map<String, Object> data = new HashMap<>();
        data.put("token", UUID.randomUUID().toString().replace("-", ""));
        data.put("user", user);
        return Result.success("注册成功", data);
    }

    /** 绘制验证码图片：浅色底 + 干扰线 + 噪点 + 随机倾斜字符，返回 base64 */
    private String renderCaptchaImage(String text) {
        BufferedImage img = new BufferedImage(CAPTCHA_W, CAPTCHA_H, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

        // 背景
        g.setColor(new Color(244, 246, 250));
        g.fillRect(0, 0, CAPTCHA_W, CAPTCHA_H);

        // 干扰线
        g.setStroke(new BasicStroke(1.2f));
        for (int i = 0; i < 8; i++) {
            g.setColor(randomColor(150, 215));
            g.drawLine(RANDOM.nextInt(CAPTCHA_W), RANDOM.nextInt(CAPTCHA_H),
                    RANDOM.nextInt(CAPTCHA_W), RANDOM.nextInt(CAPTCHA_H));
        }

        // 噪点
        for (int i = 0; i < 70; i++) {
            g.setColor(randomColor(120, 205));
            g.fillOval(RANDOM.nextInt(CAPTCHA_W), RANDOM.nextInt(CAPTCHA_H), 2, 2);
        }

        // 字符：随机颜色 + 轻微旋转
        Font font = new Font("SansSerif", Font.BOLD, 26);
        FontMetrics fm = g.getFontMetrics(font);
        int baseY = (CAPTCHA_H + fm.getAscent() - fm.getDescent()) / 2;
        int cellW = CAPTCHA_W / (text.length() + 1);
        for (int i = 0; i < text.length(); i++) {
            Graphics2D g2 = (Graphics2D) g.create();
            g2.setFont(font);
            g2.setColor(randomColor(20, 120));
            g2.translate(cellW * i + cellW / 2, baseY);
            g2.rotate((RANDOM.nextDouble() - 0.5) * 0.45);
            g2.drawString(String.valueOf(text.charAt(i)), 0, 0);
            g2.dispose();
        }
        g.dispose();

        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            ImageIO.write(img, "png", out);
            return Base64.getEncoder().encodeToString(out.toByteArray());
        } catch (Exception e) {
            throw new IllegalStateException("验证码图片生成失败", e);
        }
    }

    private Color randomColor(int min, int max) {
        return new Color(
                min + RANDOM.nextInt(max - min + 1),
                min + RANDOM.nextInt(max - min + 1),
                min + RANDOM.nextInt(max - min + 1)
        );
    }

    /** 清理过期验证码，避免内存无限增长 */
    private void purgeExpired() {
        long now = System.currentTimeMillis();
        CAPTCHA_STORE.entrySet().removeIf(e -> now - Long.parseLong(e.getValue()[1]) > CAPTCHA_EXPIRE_MS);
    }
}
