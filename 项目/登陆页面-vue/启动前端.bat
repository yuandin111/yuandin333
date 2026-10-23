@echo off
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
