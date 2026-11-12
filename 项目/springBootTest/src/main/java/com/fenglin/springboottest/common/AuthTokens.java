package com.fenglin.springboottest.common;

import com.fenglin.springboottest.entity.User;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 登录 token 存储：内存 Map + 本地文件持久化。
 *
 * 原来只用内存保存，后端重启 / devtools 热重载后所有 token 立即失效，
 * 浏览器里残留的旧 token 会让社区接口返回 401，前端随即清会话并跳回登录页，
 * 表现为「一打开社区就被踢到登录页」。现在每次增删都同步落盘，
 * 重启时从文件恢复未过期的 token，登录状态不再莫名丢失。
 *
 * 生产环境建议换 Redis / JWT；本地文件仅适用于这种单机演示项目。
 */
public class AuthTokens {

    /** token 有效期：12 小时 */
    private static final long EXPIRE_MS = 12 * 60 * 60 * 1000L;

    private static final Map<String, Entry> STORE = new ConcurrentHashMap<>();

    /** 落盘文件：后端工作目录下的隐藏文件，已在 .gitignore 中忽略 */
    private static final Path STORE_FILE = Paths.get(System.getProperty("user.dir", "."), ".auth-tokens.data");
    private static final Object FILE_LOCK = new Object();

    static {
        load();
    }

    /** token 对应的登录信息（permission：0 = 管理员权限 / 1 = 默认权限） */
    public record Entry(Long userId, String username, String role, Integer permission, long expireAt) {
        public boolean expired() {
            return System.currentTimeMillis() > expireAt;
        }
    }

    /** 登录成功后创建 token */
    public static String create(User user) {
        purgeExpired();
        String token = UUID.randomUUID().toString().replace("-", "");
        STORE.put(token, new Entry(user.getId(), user.getUsername(), user.getRole(),
                user.getPermission() == null ? User.PERMISSION_DEFAULT : user.getPermission(),
                System.currentTimeMillis() + EXPIRE_MS));
        save();
        return token;
    }

    /** 查询 token 对应的登录信息，无效或过期返回 null */
    public static Entry get(String token) {
        if (token == null || token.isBlank()) {
            return null;
        }
        Entry entry = STORE.get(token);
        if (entry == null) {
            // 热重载后静态块可能尚未执行到、或文件由另一实例更新：补一次恢复，不覆盖内存中已有的新条目
            load();
            entry = STORE.get(token);
        }
        if (entry == null) {
            return null;
        }
        if (entry.expired()) {
            STORE.remove(token);
            save();
            return null;
        }
        return entry;
    }

    /** 注销 */
    public static void remove(String token) {
        if (token != null && STORE.remove(token) != null) {
            save();
        }
    }

    private static void purgeExpired() {
        STORE.entrySet().removeIf(e -> e.getValue().expired());
    }

    /** 启动时从文件恢复未过期的 token；用 putIfAbsent 避免覆盖本次运行中新签发的 token */
    private static void load() {
        synchronized (FILE_LOCK) {
            if (!Files.isRegularFile(STORE_FILE)) {
                return;
            }
            try {
                long now = System.currentTimeMillis();
                for (String line : Files.readAllLines(STORE_FILE, StandardCharsets.UTF_8)) {
                    if (line == null || line.isBlank()) {
                        continue;
                    }
                    String[] p = line.split("\\|", -1);
                    if (p.length < 6) {
                        continue;
                    }
                    long expireAt = Long.parseLong(p[5]);
                    if (expireAt <= now) {
                        continue;
                    }
                    String role = p[3].isEmpty() ? "user" : decode(p[3]);
                    Integer permission;
                    try {
                        permission = p[4].isEmpty() ? User.PERMISSION_DEFAULT : Integer.parseInt(p[4]);
                    } catch (NumberFormatException e) {
                        permission = User.PERMISSION_DEFAULT;
                    }
                    STORE.putIfAbsent(p[0], new Entry(Long.parseLong(p[1]), decode(p[2]),
                            role, permission, expireAt));
                }
            } catch (Exception ignored) {
                // 文件损坏 / 权限不足时退回纯内存模式，不影响登录
            }
        }
    }

    /** 把当前有效 token 原子写入文件（先写临时文件再替换，避免写一半被读到） */
    private static void save() {
        synchronized (FILE_LOCK) {
            try {
                long now = System.currentTimeMillis();
                List<String> lines = new ArrayList<>();
                STORE.forEach((token, e) -> {
                    if (e.expireAt() > now) {
                        lines.add(String.join("|",
                                token,
                                String.valueOf(e.userId()),
                                encode(e.username()),
                                encode(e.role()),
                                String.valueOf(e.permission() == null ? User.PERMISSION_DEFAULT : e.permission()),
                                String.valueOf(e.expireAt())));
                    }
                });
                Path parent = STORE_FILE.toAbsolutePath().getParent();
                if (parent != null) {
                    Files.createDirectories(parent);
                }
                Path tmp = STORE_FILE.resolveSibling(STORE_FILE.getFileName().toString() + ".tmp");
                Files.write(tmp, lines, StandardCharsets.UTF_8,
                        StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
                try {
                    Files.move(tmp, STORE_FILE, StandardCopyOption.REPLACE_EXISTING,
                            StandardCopyOption.ATOMIC_MOVE);
                } catch (AtomicMoveNotSupportedException ex) {
                    Files.move(tmp, STORE_FILE, StandardCopyOption.REPLACE_EXISTING);
                }
            } catch (IOException ignored) {
                // 落盘失败时仅退回内存模式，不阻断登录
            }
        }
    }

    /** 用户名/角色可能含中文或分隔符，统一 Base64 后再拼进单行文本 */
    private static String encode(String value) {
        return Base64.getEncoder().encodeToString((value == null ? "" : value).getBytes(StandardCharsets.UTF_8));
    }

    private static String decode(String value) {
        if (value == null || value.isEmpty()) {
            return "";
        }
        try {
            return new String(Base64.getDecoder().decode(value), StandardCharsets.UTF_8);
        } catch (IllegalArgumentException e) {
            return value;
        }
    }
}
