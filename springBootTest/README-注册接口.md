# fanren-login 后端改造说明（Spring Boot 3 + MyBatis-Plus + MySQL）

前端 `fanren-login-vue`（目录 `登陆页面-vue`）的注册/登录页面已就绪，本次改造完成后端，
技术栈：**Spring Boot 3.4.5 + MyBatis-Plus 3.5.9 + MySQL 8 + BCrypt**。

---

## 一、先建库建表

脚本位置：`sql/fanren_login.sql`

```sql
CREATE DATABASE IF NOT EXISTS `fanren_login`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE `fanren_login`;

CREATE TABLE `t_user` (
  `id`              BIGINT       NOT NULL AUTO_INCREMENT                       COMMENT '主键 ID',
  `username`        VARCHAR(50)  NOT NULL                                      COMMENT '用户名（唯一）',
  `password`        VARCHAR(100) NOT NULL                                      COMMENT '密码（BCrypt 密文，定长 60）',
  `email`           VARCHAR(100) NOT NULL                                      COMMENT '邮箱（唯一）',
  `nickname`        VARCHAR(50)  DEFAULT NULL                                  COMMENT '昵称',
  `status`          TINYINT      NOT NULL DEFAULT 1                            COMMENT '状态：1-正常，0-禁用',
  `token`           VARCHAR(64)  DEFAULT NULL                                  COMMENT '登录令牌',
  `token_expire_at` DATETIME     DEFAULT NULL                                  COMMENT '令牌过期时间',
  `create_time`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP            COMMENT '创建时间',
  `update_time`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email`    (`email`),
  KEY `idx_token` (`token`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT = '用户表';
```

执行方式（任选一种）：

```bash
mysql -u root -p < sql/fanren_login.sql
```

或在 IDEA / Navicat / DataGrip 中打开该脚本全量执行。

---

## 二、修改数据库连接

`src/main/resources/application-dev.properties`

```properties
server.port=8081
spring.datasource.url=jdbc:mysql://127.0.0.1:3306/fanren_login?useUnicode=true&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai
spring.datasource.username=root
spring.datasource.password=123456
```

> 两个易踩的坑：
> 1. `characterEncoding` 必须写 `UTF-8`，**不能**写 `utf8mb4`（那是 MySQL 的字符集名，不是 Java 字符集名，
>    写成 utf8mb4 会报 `Unsupported character encoding 'utf8mb4'`，所有数据库操作都会 500）。
> 2. MyBatis-Plus 版本固定为 **3.5.8**。3.5.9 起 `PaginationInnerInterceptor` 被拆分出去，
>    沿用旧写法会编译失败。

---

## 三、启动前后端

| 项目 | 启动方式 | 地址 |
| --- | --- | --- |
| 后端 | 运行 `SpringBootTestApplication`，或 `mvn spring-boot:run` | http://localhost:8081/api |
| 前端 | `cd 登陆页面-vue && npm install && npm run dev` | http://localhost:5173 |

前端根目录已放置 `.env`：

```properties
VITE_API_BASE=http://localhost:8081/api
```

> 注意：`.env` 修改后必须**重启 vite** 才会生效；缺少该变量时前端会走“演示模式”，不会真正请求后端。

跨域已在 `config/CorsConfig.java` 中放行 `localhost:5173`。

---

## 四、接口文档

统一前缀：`/api`（`server.servlet.context-path`）

### 1. 注册 `POST /api/auth/register`

请求体：

```json
{ "username": "zhangsan", "email": "zs@test.com", "password": "123456" }
```

成功 `200`：

```json
{
  "code": 200,
  "message": "注册成功",
  "token": "5f3c9a1e...",
  "user": { "id": 1, "username": "zhangsan", "email": "zs@test.com", "nickname": "zhangsan", "createTime": "2026-09-24 14:30:00" }
}
```

失败：

| HTTP | 响应 | 场景 |
| --- | --- | --- |
| 400 | `{"code":400,"message":"请输入有效的邮箱地址","data":null}` | 参数校验失败 |
| 400 | `{"code":409,"message":"用户名已被注册","data":null}` | 用户名重复 |
| 400 | `{"code":409,"message":"邮箱已被注册","data":null}` | 邮箱重复 |

前端 `RegisterCard.vue` 读取的正是 `error.response.data.message`，提示会直接显示在卡片上。

### 2. 登录 `POST /api/auth/login`

请求体：

```json
{ "username": "zhangsan", "password": "123456" }
```

`username` 也可填邮箱（页面提示为“用户名 / 邮箱”）。成功返回同上；
账号不存在或密码错误返回 `{"code":401,"message":"用户名或密码错误"}`。

### 3. 手动测试（curl）

```bash
# 注册
curl -X POST http://localhost:8081/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"zhangsan\",\"email\":\"zs@test.com\",\"password\":\"123456\"}"

# 重复注册（验证唯一性）
curl -X POST http://localhost:8081/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"zhangsan\",\"email\":\"zs2@test.com\",\"password\":\"123456\"}"

# 登录
curl -X POST http://localhost:8081/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"zhangsan\",\"password\":\"123456\"}"
```

---

### 3. 获取当前登录用户 `GET /api/auth/me`（需要登录）

请求头（二选一）：

```
Authorization: Bearer <token>
X-Token: <token>
```

成功 `200`：

```json
{"code":200,"message":"success","data":{"id":2,"username":"wangwu","email":"ww@test.com","nickname":"wangwu","createTime":"2026-09-24 14:55:52"}}
```

未携带令牌：`401 {"code":401,"message":"未登录，请先登录","data":null}`
令牌非法或过期：`401 {"code":401,"message":"登录已失效，请重新登录","data":null}`

### 关于令牌（JWT）

- 注册 / 登录返回的 `token` 是 **JWT**（HS256），载荷：`sub`=用户ID、`username`=用户名，默认有效期 **7 天**。
- 令牌**无状态**，不写数据库，所以 `t_user` 表里没有 token 字段（旧版若有，见 SQL 脚本第 4 节迁移语句）。
- 密钥在 `application.properties`：`jwt.secret`（**上线前必须更换**）、`jwt.expiration-hours`。
- 需要保护新接口时，在 `config/WebConfig.java` 的 `addPathPatterns` 里加路径即可；
  当前 `/user/**` 已被拦截，但排除了旧的 Thymeleaf 演示页（`/user/to_login` 等）。

## 五、实测结果（本机 MySQL 8.0.39 已验证）

数据库 `fanren_login`、表 `t_user` 已创建，以下 9 个用例全部通过：

| 用例 | 结果 |
| --- | --- |
| 注册 zhangsan | `200 {"code":200,"message":"注册成功","token":"203d…","user":{"id":1,...}}` |
| 用户名重复 | `{"code":409,"message":"用户名已被注册"}` |
| 邮箱重复 | `{"code":409,"message":"邮箱已被注册"}` |
| 邮箱格式错误 | `{"code":400,"message":"请输入有效的邮箱地址"}` |
| 密码不足 6 位 | `{"code":400,"message":"密码长度需为 6-32 位"}` |
| 用户名 + 密码登录 | `200`，返回新 token |
| 密码错误 | `{"code":401,"message":"用户名或密码错误"}` |
| 用邮箱登录 | `200`，登录成功 |
| 用户不存在 | `{"code":401,"message":"用户名或密码错误"}`（不泄露账号是否存在） |

登录态（JWT）同样实测通过：

| 用例 | 结果 |
| --- | --- |
| 注册/登录返回 token | JWT 三段式，header 解码为 `{"alg":"HS256"}` |
| 带 `Authorization: Bearer <token>` 访问 /auth/me | 200，返回当前用户信息 |
| 带 `X-Token: <token>` 访问 /auth/me | 200 |
| 不带 token | 401 `未登录，请先登录` |
| 伪造 token | 401 `登录已失效，请重新登录` |
| 旧 Thymeleaf 页面 /user/to_login | 200，未被误拦截 |

密码以 BCrypt 落库（`$2a$10$` 开头，长度 60），**不存在明文密码**。
CORS 预检 `OPTIONS /api/auth/register`（Origin: http://localhost:5173）返回
`Access-Control-Allow-Origin: http://localhost:5173`，前端可直连。

## 六、本次新增/修改的文件

```
pom.xml                                       新增 MyBatis-Plus / MySQL / validation / spring-security-crypto
src/main/resources/application.properties     新增 context-path=/api，日志配置
src/main/resources/application-dev.properties 新增数据源与 MyBatis-Plus 配置
sql/fanren_login.sql                          建库建表脚本（文本）
src/main/java/com/fenglin/springboottest/
├── common/
│   ├── Result.java                 统一响应体
│   ├── AuthResponse.java           注册/登录响应体（token + user）
│   ├── BusinessException.java      业务异常
│   ├── JwtUtil.java                JWT 签发与校验（HS256）
│   └── GlobalExceptionHandler.java 全局异常处理
├── config/
│   ├── CorsConfig.java             跨域放行 5173
│   ├── MybatisPlusConfig.java      Mapper 扫描 + 分页插件
│   ├── AppConfig.java              BCryptPasswordEncoder
│   ├── AuthInterceptor.java        校验请求头里的 JWT
│   └── WebConfig.java              注册拦截器、配置受保护路径
├── controller/AuthController.java  POST /auth/register、/auth/login
├── dto/RegisterRequest.java        注册入参 + 校验注解
├── dto/LoginRequest.java           登录入参 + 校验注解
├── dto/UserVO.java                 用户信息视图（不含密码）
├── entity/User.java                t_user 实体
├── mapper/UserMapper.java          BaseMapper
└── service/UserService.java + impl/UserServiceImpl.java  注册/登录业务逻辑
```

## 七、实现要点

1. **密码不明文存储**：使用 `BCryptPasswordEncoder` 加密，登录时用 `matches()` 比对。
2. **唯一性双重保障**：Service 层先查重给出友好提示，数据库 `uk_username` / `uk_email` 唯一索引兜底。
3. **前端字段严格对齐**：`username / email / password`，成功给 `token` 与 `user`，失败给 `message`。
4. **不使用 Lombok**：实体手写 getter/setter，避免 IDEA 未装 Lombok 插件导致编译失败。
5. **JWT 显式指定 HS256**：`signWith(key)` 会让 jjwt 按密钥长度自动选算法（长密钥会变成 HS384/HS512），
   所以写成 `signWith(key, Jwts.SIG.HS256)`，保证签名算法确定。
