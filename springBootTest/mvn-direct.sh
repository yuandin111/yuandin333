#!/bin/sh
# 直接通过 java 启动 Maven 的 classworlds 启动器，绕过 mvn 脚本在 Git Bash 下的 Unix 路径问题。
JAVA="/c/Program Files/Zulu/zulu-21/bin/java"
MVN_HOME="/c/Users/Administrator/.m2/wrapper/dists/apache-maven-3.9.16-bin/5grr65jo27hi51sujmtcldfovl/apache-maven-3.9.16"
MVN_HOME_WIN=$(cygpath -w "$MVN_HOME")
CLASSWORLDS_WIN=$(cygpath -w "$MVN_HOME/boot/plexus-classworlds-2.11.0.jar")
PROJ_WIN=$(cygpath -w "$PWD")
exec "$JAVA" \
  --add-opens java.base/java.lang=ALL-UNNAMED \
  --enable-native-access=ALL-UNNAMED \
  -classpath "$CLASSWORLDS_WIN" \
  "-Dclassworlds.conf=$MVN_HOME_WIN/bin/m2.conf" \
  "-Dmaven.home=$MVN_HOME_WIN" \
  "-Dlibrary.jansi.path=$MVN_HOME_WIN/lib/jansi-native" \
  "-Dmaven.multiModuleProjectDirectory=$PROJ_WIN" \
  org.codehaus.plexus.classworlds.launcher.Launcher "$@"
