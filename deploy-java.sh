#!/bin/bash

# 配置项
PROJECT_DIR="/root/project"  # 替换为你的项目路径
GIT_REPO="git@github.com:saul-z/core.git"
JAR_NAME="core.jar"
MAVEN_CMD="mvn clean package -DskipTests"  # 可根据需要调整 Maven 命令
JAVA_CMD="nohup java -jar ${JAR_NAME} > /dev/null 2>&1 &"

export CORE_FILEPATH="/root/project/file"
export MYSQL_PASSWORD="Mysqlpassword1!"


# 检查项目目录是否存在
if [ ! -d "${PROJECT_DIR}" ]; then
    echo "项目目录不存在，开始克隆项目..."
    git clone ${GIT_REPO} ${PROJECT_DIR}
    if [ $? -ne 0 ]; then
        echo "克隆项目失败，请检查 Git 仓库地址或网络连接。"
        exit 1
    fi
else
    echo "项目目录已存在，开始拉取最新代码..."
    cd ${PROJECT_DIR}
    git pull
    if [ $? -ne 0 ]; then
        echo "拉取最新代码失败，请检查 Git 仓库状态。"
        exit 1
    fi
fi

# 构建项目
echo "开始构建项目..."
cd ${PROJECT_DIR}
${MAVEN_CMD}
if [ $? -ne 0 ]; then
    echo "Maven 构建失败，请检查项目代码。"
    exit 1
fi

# 查找生成的 JAR 文件
JAR_PATH=$(find target -type f -name "${JAR_NAME}")
if [ -z "${JAR_PATH}" ]; then
    echo "未找到可执行的 JAR 文件。"
    exit 1
fi

# 停止正在运行的应用（如果有）
EXIST_PID=$(pgrep -f "${JAR_NAME}")
if [ -n "${EXIST_PID}" ]; then
    echo "发现正在运行的应用 (PID: ${EXIST_PID})，准备停止..."
    kill -9 ${EXIST_PID}
    if [ $? -ne 0 ]; then
        echo "无法停止正在运行的应用。"
        exit 1
    fi
    echo "已停止正在运行的应用。"
fi

# 运行新的 JAR 文件
echo "开始运行新的应用..."
nohup java -jar "${JAR_PATH}" > /dev/null 2>&1 &
NEW_PID=$!

# 等待应用启动（例如 10 秒）
sleep 10

# 检查应用是否在运行
if ps -p ${NEW_PID} > /dev/null 2>&1; then
    echo "应用已成功启动，PID: ${NEW_PID}。"
else
    echo "应用启动失败"
    exit 1
fi