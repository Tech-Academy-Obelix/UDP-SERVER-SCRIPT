#!/bin/bash

REPO_URL="https://github.com/Tech-Academy-Obelix/HomeworkPlatform.git"
TARGET_DIR="HomeworkPlatform"
PID_FILE="platform.pid"

if [ -d "$TARGET_DIR" ]; then
    cd "$TARGET_DIR" || exit
    git pull origin main
else
    git clone "$REPO_URL"
    cd "$TARGET_DIR" || exit
fi

if [ -f "pom.xml" ]; then
    BUILD_TOOL="maven"
elif [ -f "build.gradle" ]; then
    BUILD_TOOL="gradle"
else
    exit 1
fi

if [ "$BUILD_TOOL" == "maven" ]; then
    mvn clean package -DskipTests
    JAR_FILE=$(find target -name "*.jar" | head -n 1)
elif [ "$BUILD_TOOL" == "gradle" ]; then
    ./gradlew build -x test
    JAR_FILE=$(find build/libs -name "*.jar" | head -n 1)
fi

if [ ! -f "$JAR_FILE" ]; then
    exit 1
fi

nohup java -jar "$JAR_FILE" > output.log 2>&1 &
echo $! > "$PID_FILE"
