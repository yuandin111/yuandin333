@echo off
chcp 936 >nul
cd /d "%~dp0"

REM ===== 1. Self-heal: make sure maven wrapper config exists =====
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
