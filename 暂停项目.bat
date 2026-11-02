@echo off
chcp 936 >nul
echo 正在停止后端(8081)...
for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":8081" ^| findstr "LISTENING"') do taskkill /f /t /pid %%P >nul 2>&1
echo 正在停止前端(5173)...
for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":5173" ^| findstr "LISTENING"') do taskkill /f /t /pid %%P >nul 2>&1
echo 已停止前后端(MySQL 服务未动)。
pause
