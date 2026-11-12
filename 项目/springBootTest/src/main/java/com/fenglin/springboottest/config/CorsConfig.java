package com.fenglin.springboottest.config;

import com.fenglin.springboottest.interceptor.AdminAuthInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * 跨域配置：允许 Vue 前端（默认 5173 端口）调用后端接口
 * 同时注册后台管理接口的鉴权拦截器 与 上传图片的静态资源映射
 */
@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Autowired
    private AdminAuthInterceptor adminAuthInterceptor;

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                // 本机 + 局域网：Vite 以 0.0.0.0 对外提供 5173，局域网设备会用本机 IP 打开前端；
                // 不放行对应 origin 的话，登录/内容等接口会被浏览器 CORS 拦截。
                .allowedOriginPatterns(
                        "http://localhost:5173",
                        "http://127.0.0.1:5173",
                        "http://192.168.68.53:5173",
                        "http://192.168.*:5173",
                        "http://10.*:5173",
                        "http://172.*:5173")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(adminAuthInterceptor).addPathPatterns("/api/admin/**");
    }

    /**
     * 上传图片静态映射：工作目录 uploads/ → http://localhost:8081/uploads/xxx.png
     * 注意 file: 前缀的相对路径以进程工作目录（springBootTest 项目根）为基准，末尾斜杠不能省
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:uploads/");
    }
}
