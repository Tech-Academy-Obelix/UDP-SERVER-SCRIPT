#!/bin/bash

BACKEND_REPO="https://github.com/Tech-Academy-Obelix/HomeworkPlatform.git"
FRONTEND_REPO="https://github.com/Tech-Academy-Obelix/web-frontend"
BACKEND_DIR="HomeworkPlatform"
FRONTEND_DIR="web-frontend"
BACKEND_PID_FILE="platform.pid"
UDP_PID_FILE="udp_server.pid"
FRONTEND_PID_FILE="frontend.pid"

# Backend
if [ -d "$BACKEND_DIR" ]; then
    cd "$BACKEND_DIR" || exit
    git pull origin main
else
    git clone "$BACKEND_REPO"
    cd "$BACKEND_DIR" || exit
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
echo $! > "$BACKEND_PID_FILE"

# UDP Server
if [ -f "$UDP_PID_FILE" ]; then
    kill $(cat "$UDP_PID_FILE") 2>/dev/null
    rm "$UDP_PID_FILE"
fi


# Frontend
if [ -d "$FRONTEND_DIR" ]; then
    cd "$FRONTEND_DIR" || exit
    git pull origin main
else
    git clone "$FRONTEND_REPO"
    cd "$FRONTEND_DIR" || exit
fi

if [ -f "package.json" ]; then
    npm install
    nohup npm start > frontend.log 2>&1 &
    echo $! > "../$FRONTEND_PID_FILE"
else
    exit 1
fi
