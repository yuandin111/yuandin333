# -*- coding: utf-8 -*-
"""
一次性生成器：为 登陆页面-vue + springBootTest 生成 启动/暂停脚本(GBK) 与备忘(UTF-8 BOM)。
电脑每次重置只会删 node_modules 和 target；本文件若也被删，重新运行它即可再生成全部脚本。
运行：python 生成项目脚本.py
"""
import os

DESKTOP = r"C:\Users\Administrator\Desktop"
ROOT = os.path.join(DESKTOP, "项目")   # 两个项目实际都放在 Desktop\项目\ 下
BACKEND = os.path.join(ROOT, "springBootTest")
FRONTEND = os.path.join(ROOT, "登陆页面-vue")

# ---------- 后端启动脚本 ----------
backend_bat = r'''@echo off
chcp 936 >nul
cd /d "%~dp0"

REM ===== 1. Self-heal: make sure maven wrapper config exists =====
REM (NOTE: keep this file pure ASCII! Chinese chars in .bat can break cmd parsing
REM  with "error: unexpected token" and kill the script before maven even runs.)
if not exist ".mvn\wrapper\maven-wrapper.properties" (
    if not exist ".mvn\wrapper" md ".mvn\wrapper"
    > .mvn\wrapper\maven-wrapper.properties echo distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.16/apache-maven-3.9.16-bin.zip
)

REM ===== 2. Clear IDE-injected SERVER__PORT so 8081 wins =====
set "SERVER__PORT="

REM ===== 3. Init database (idempotent; needs MySQL running) =====
set "MYSQLBIN="
if exist "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" set "MYSQLBIN=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
if not defined MYSQLBIN if exist "C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysql.exe" set "MYSQLBIN=C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysql.exe"
if defined MYSQLBIN (
    echo [1/3] Init database springboot_test ...
    "%MYSQLBIN%" -uroot -p123456 < "%~dp0sql\springboot_test.sql" 2>nul
) else (
    echo [note] mysql client not found, skip db init.
)

REM ===== 4. Start backend, force port 8081 =====
echo [2/3] Building and starting Spring Boot backend on port 8081, first run may take 1-2 min...
call mvnw.cmd spring-boot:run -Dspring-boot.run.arguments=--server.port=8081
echo [3/3] Backend exited.
pause
'''

# ---------- 前端启动脚本 ----------
frontend_bat = r'''@echo off
chcp 936 >nul
cd /d "%~dp0"

REM ===== 0. PATH 兜底：保证双击运行时能找到 node / npm =====
set "PATH=D:\Program Files\nodejs;C:\Users\Administrator\.workbuddy\binaries\node\versions\22.22.2-2;%PATH%"
where node >nul 2>nul || (echo [错误] 未找到 node.exe，请确认 Node.js 已安装或修正 PATH。 & pause & exit /b 1)
where npm  >nul 2>nul || (echo [错误] 未找到 npm，请确认 Node.js 已安装或修正 PATH。 & pause & exit /b 1)
echo Node 版本:
node -v

REM ===== 1. 自愈：确保 .env 存在且指向后端 /api =====
if not exist ".env" (
    echo [自愈] 缺少 .env，正在创建...
    > .env echo VITE_API_BASE=http://localhost:8081/api
)
findstr /c:"VITE_API_BASE" ".env" >nul 2>nul || (>> .env echo VITE_API_BASE=http://localhost:8081/api)
echo [配置] VITE_API_BASE 已就绪(缺失会让前端走演示模式，不连后端)。

REM ===== 2. 安装依赖(node_modules 每次重启会被删，需重装) =====
echo [1/3] 安装前端依赖...
call npm install --no-audit --no-fund
if errorlevel 1 (
    echo [错误] npm install 失败，请查看上方日志后重试。
    pause
    exit /b 1
)

REM ===== 3. 前置检查：后端 8081 是否已启动 =====
echo [2/3] 检查后端 http://localhost:8081 ...
netstat -ano | findstr ":8081" | findstr "LISTENING" >nul 2>nul
if errorlevel 1 (
    echo   [警告] 后端 8081 未在监听，登录/注册将失败。
    echo   请先双击 springBootTest\启动后端.bat
) else (
    echo   后端已就绪。
)

REM ===== 4. 启动前端 =====
echo [3/3] 启动 Vue 前端(端口 5173)...
call npm run dev
echo 前端已退出。
pause
'''

# ---------- 一键启动(桌面) ----------
start_bat = r'''@echo off
chcp 936 >nul
echo 正在启动前后端(会弹出两个窗口)...
start "SpringBoot后端-8081" cmd /k "%~dp0项目\springBootTest\启动后端.bat"
start "Vue前端-5173" cmd /k "%~dp0项目\登陆页面-vue\启动前端.bat"
echo.
echo 前端: http://localhost:5173/
echo 后端: http://localhost:8081/api/auth/login
echo 测试账号: admin / 123456
echo.
pause
'''

# ---------- 一键暂停(桌面) ----------
stop_bat = r'''@echo off
chcp 936 >nul
echo 正在停止后端(8081)...
for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":8081" ^| findstr "LISTENING"') do taskkill /f /t /pid %%P >nul 2>&1
echo 正在停止前端(5173)...
for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":5173" ^| findstr "LISTENING"') do taskkill /f /t /pid %%P >nul 2>&1
echo 已停止前后端(MySQL 服务未动)。
pause
'''

# ---------- 给 AI 自己的备忘 ----------
notes = r'''==================== 登陆页面-vue + springBootTest 启动备忘 ====================
(给 AI 自己看：每次重启后按此操作，别再从头排查)

【是什么】前后端分离登录项目
  - 前端 登陆页面-vue：Vue3 + Vite + axios，端口 5173，无自己的数据库
  - 后端 springBootTest：Spring Boot 3.4.5 + MyBatis-Plus 3.5.7 + MySQL，端口 8081
  - 数据库：本地 MySQL 8.0(localhost:3306)，库 springboot_test，表 sys_user
  - 测试账号：admin / 123456(密码 MD5 存储)

【实际路径】(注意：两个项目都在 Desktop\项目\ 下，不在桌面根)
  C:\Users\Administrator\Desktop\项目\登陆页面-vue
  C:\Users\Administrator\Desktop\项目\springBootTest
  重新生成脚本的 生成项目脚本.py 也在 Desktop\项目\ 里，直接 python 生成项目脚本.py 即可。

【端口】前端 5173 / 后端 8081 / MySQL 3306

【一键启动/暂停】在桌面(两个项目文件夹的上一级)：
  - 启动项目.bat  -> 弹出两个窗口分别起后端、前端
  - 暂停项目.bat  -> 按端口杀掉 8081 和 5173 的进程(不动 MySQL)
  每个项目里也各有 启动后端.bat / 启动前端.bat 可单独启动。

【关键坑(必记，别再踩)】
1) 端口劫持：WorkBuddy/CodeBuddy 这个 IDE 会往环境注入 SERVER__PORT=52242；
   Spring Boot 中 OS 环境变量优先级高于 application-*.properties，会把 server.port
   覆盖成 52242，又与 IDE 自身端口冲突 -> 后端启动失败(Tomcat initialized with port 52242)。
   解决：启动强制 --server.port=8081(命令行参数优先级最高)。脚本已内置。
   我在 Bash 里跑后端必须先 unset SERVER__PORT，否则一样中招。
2) 每次重启 node_modules、target 会被删 -> 必须 npm install + maven 重新构建。
   脚本已内置；所以启动前别指望这两个文件夹存在。
3) 前后端路径不一致：前端 auth.js 写 /auth/login，后端实际 /api/auth/login。
   靠前端 .env 的 VITE_API_BASE=http://localhost:8081/api 对齐。
   不配 .env 前端走“演示模式”(假登录，不连库)。

4) 数据库 springboot_test 不一定存在！后端会启动成功但登录报
   java.sql.SQLSyntaxErrorException: Unknown database 'springboot_test'。
   手动补一次(脚本含 DROP TABLE，会重置用户表)：
   "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -uroot -p123456 < springBootTest\sql\springboot_test.sql
5) .bat 文件必须是【GBK 编码 + CRLF 换行】！用编辑器/工具写成 UTF-8 或 LF 换行会导致
   if not exist ".env" ( ... ) 这类括号代码块解析失败 -> .env 建不出来 -> 前端静默降级为
   "演示模式"(假登录，压根不请求后端)，表现就是"启动脚本失效"。
   生成脚本.py 里已用 encoding="gbk", newline="\r\n" 保证，别再用普通写入工具改这两个 bat。
6) vite 只在启动时读 .env，改完 .env 必须重启 dev server 才生效。
   验证是否生效：curl http://localhost:5173/src/services/auth.js | head
   看到 "VITE_API_BASE":"http://localhost:8081/api" 才算真的连上后端。

【项目原本缺失、已补齐(重置丢失就用 项目\生成项目脚本.py 重跑)】
  - springBootTest/.mvn/wrapper/maven-wrapper.properties (maven 3.9.16) —— 原来没有，mvnw 直接报错
  - 登陆页面-vue/.env (VITE_API_BASE=http://localhost:8081/api)
  - springBootTest/mvn-direct.sh —— 我在 Git Bash 下跑后端专用(mvn 脚本在 Git Bash 会把
    unix 路径传给 Windows java 导致 classworlds 报错；此脚本直接调 java 启动 classworlds 绕过)

【后端手动启动(Bash 环境，供 AI 自己)】
  cd springBootTest && unset SERVER__PORT && ./mvn-direct.sh spring-boot:run

【数据库】MySQL 8.0 root/123456；初始化脚本 springBootTest/sql/springboot_test.sql(幂等，可反复跑)；
  MySQL 需运行中(系统服务，一般开机自启)。

【登录自测】
  curl -X POST http://localhost:8081/api/auth/login -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"123456\"}"
  成功 {"code":200,...,"token":...}；错误密码返回 code:401。
================================================================================
'''


def w(path, data, enc):
    data = data.replace("\r\n", "\n").replace("\r", "\n")  # 统一换行
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding=enc, newline="\r\n") as f:
        f.write(data)
    print("written:", path, "(%s)" % enc)


# 脚本(GBK，配合 chcp 936)
w(os.path.join(DESKTOP, "启动项目.bat"), start_bat, "gbk")
w(os.path.join(DESKTOP, "暂停项目.bat"), stop_bat, "gbk")
w(os.path.join(BACKEND, "启动后端.bat"), backend_bat, "gbk")
w(os.path.join(FRONTEND, "启动前端.bat"), frontend_bat, "gbk")
# 备忘(UTF-8 BOM，记事本可直接看)
w(os.path.join(BACKEND, "启动备忘.txt"), notes, "utf-8-sig")
# 补齐原本缺失的前置文件
w(os.path.join(BACKEND, ".mvn", "wrapper", "maven-wrapper.properties"),
  "distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.16/apache-maven-3.9.16-bin.zip\n",
  "utf-8")
w(os.path.join(FRONTEND, ".env"), "VITE_API_BASE=http://localhost:8081/api\n", "utf-8")
print("全部完成。")
