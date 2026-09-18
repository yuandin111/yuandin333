@echo off
set "PATH=D:\Program Files\nodejs;C:\Users\Administrator\.workbuddy\binaries\node\versions\22.22.2-2;%PATH%"
cd /d "%~dp0"
where node >nul 2>nul || (echo [Error] Node.js not found. Please install Node.js first. & pause & exit /b 1)
echo ============================================
echo   Vue Login - Starting dev server...
echo   Browser will open: http://localhost:5173
echo   Close this window to stop the server.
echo ============================================
call npm run dev
