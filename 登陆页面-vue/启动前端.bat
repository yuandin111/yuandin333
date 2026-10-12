@echo off
chcp 936 >nul
cd /d "%~dp0"

REM ===== 1. 自愈：补回 .env，指到后端 /api =====
if not exist ".env" (
    > .env echo VITE_API_BASE=http://localhost:8081/api
)

REM ===== 2. 安装依赖(node_modules 每次重启会被删，需重装) =====
echo [1/2] 安装前端依赖...
call npm install

REM ===== 3. 启动前端 =====
echo [2/2] 启动 Vue 前端(端口 5173)...
call npm run dev
pause
