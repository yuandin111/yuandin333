@echo off
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
