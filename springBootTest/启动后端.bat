@echo off
chcp 936 >nul
cd /d "%~dp0"

REM ===== 1. 自愈：补回缺失的 maven 包装器配置 =====
if not exist ".mvn\wrapper\maven-wrapper.properties" (
    if not exist ".mvn\wrapper" md ".mvn\wrapper"
    > .mvn\wrapper\maven-wrapper.properties echo distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.16/apache-maven-3.9.16-bin.zip
)

REM ===== 2. 清掉 IDE 注入的 SERVER__PORT，防止端口被劫持到 52242 =====
set "SERVER__PORT="

REM ===== 3. 尽力初始化数据库(幂等；需 MySQL 已启动) =====
set "MYSQLBIN="
if exist "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" set "MYSQLBIN=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
if not defined MYSQLBIN if exist "C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysql.exe" set "MYSQLBIN=C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysql.exe"
if defined MYSQLBIN (
    echo [1/3] 初始化数据库 springboot_test ...
    "%MYSQLBIN%" -uroot -p123456 < "%~dp0sql\springboot_test.sql" 2>nul
) else (
    echo [提示] 未找到 mysql 客户端，跳过初始化(若数据库已存在则无影响)。
)

REM ===== 4. 启动后端(强制 8081；target 每次重启会被删，这里会重新构建) =====
echo [2/3] 正在构建并启动 Spring Boot 后端(端口 8081)，首次需下载依赖请稍候...
call mvnw.cmd spring-boot:run -Dspring-boot.run.arguments=--server.port=8081
echo [3/3] 后端已退出。
pause
