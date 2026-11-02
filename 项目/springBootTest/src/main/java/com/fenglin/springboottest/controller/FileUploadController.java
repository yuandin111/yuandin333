package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * 后台图片上传接口（/api/admin/** 由 AdminAuthInterceptor 统一做管理员鉴权）
 * 图片保存在工作目录 uploads/ 下，通过 /uploads/** 静态资源映射对外访问（CorsConfig 中注册）
 */
@RestController
@RequestMapping("/api/admin")
public class FileUploadController {

    /** 允许的图片扩展名 */
    private static final Set<String> ALLOWED_EXT = Set.of("png", "jpg", "jpeg", "gif", "webp");
    /** 单文件大小上限：5MB */
    private static final long MAX_SIZE = 5L * 1024 * 1024;
    /** 上传目录（相对工作目录，即 springBootTest 项目根下的 uploads/） */
    private static final Path UPLOAD_DIR = Paths.get("uploads");

    /**
     * 上传图片，返回 { url: "/uploads/xxx.png" }
     * 该 url 存入内容的 image_url 字段，前端经 resolveUrl 拼接后端地址后展示
     */
    @PostMapping("/upload")
    public Result<Map<String, String>> upload(@RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return Result.error(400, "请选择要上传的图片");
        }
        String ext = extOf(file.getOriginalFilename());
        if (!ALLOWED_EXT.contains(ext)) {
            return Result.error(400, "仅支持 png / jpg / jpeg / gif / webp 格式的图片");
        }
        if (file.getSize() > MAX_SIZE) {
            return Result.error(400, "图片大小不能超过 5MB");
        }

        String filename;
        try {
            Files.createDirectories(UPLOAD_DIR);
            // 随机文件名，避免中文/重名/路径注入
            filename = UUID.randomUUID().toString().replace("-", "") + "." + ext;
            // 用 Files.copy 而非 transferTo：transferTo 的相对路径语义依赖 servlet 临时目录，不可靠
            Files.copy(file.getInputStream(), UPLOAD_DIR.resolve(filename), StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            return Result.error(500, "保存文件失败：" + e.getMessage());
        }

        return Result.success("上传成功", Map.of("url", "/uploads/" + filename));
    }

    /** 取小写扩展名，无扩展名返回空串 */
    private String extOf(String filename) {
        if (filename == null) {
            return "";
        }
        int dot = filename.lastIndexOf('.');
        if (dot < 0 || dot == filename.length() - 1) {
            return "";
        }
        return filename.substring(dot + 1).toLowerCase();
    }
}
