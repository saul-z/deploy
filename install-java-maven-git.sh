#!/bin/bash

# 确保脚本以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请使用 root 权限运行此脚本，例如使用 sudo。"
  exit 1
fi

# 更新系统包
echo "更新系统包..."
yum update -y

# 安装必要的工具
echo "安装必要的工具..."
yum install -y wget tar gzip vim

# 安装 JDK 17
echo "开始安装 JDK 17..."

# 设置 JDK 下载链接和包名
JDK_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_x64_linux_hotspot_17.0.13_11.tar.gz"
JDK_PACKAGE="OpenJDK17U-jdk_x64_linux_hotspot_17.0.13_11.tar.gz"
JDK_INSTALL_DIR="/usr/local/jdk"

# 下载 JDK 17
echo "下载 JDK 17..."
wget -O /tmp/${JDK_PACKAGE} ${JDK_URL}
if [ $? -ne 0 ]; then
  echo "下载 JDK 17 失败，请检查 URL 或网络连接。"
  exit 1
fi

# 解压 JDK
echo "解压 JDK 17..."
tar -zxvf /tmp/${JDK_PACKAGE} -C /usr/local/
if [ $? -ne 0 ]; then
  echo "解压 JDK 17 失败。"
  exit 1
fi

# 重命名解压后的目录为统一名称
# 假设解压后的目录为 `jdk-17.0.13+11`

mv /usr/local/jdk-17.0.13+11 /usr/local/jdk17

# 设置环境变量
echo "设置 JDK 环境变量..."
cat << EOF > /etc/profile.d/jdk.sh
export JAVA_HOME=/usr/local/jdk17
export PATH=\$PATH:\$JAVA_HOME/bin
EOF

# 使环境变量立即生效
source /etc/profile.d/jdk.sh

# 验证 JDK 安装
echo "验证 JDK 安装..."
java -version
if [ $? -ne 0 ]; then
  echo "JDK 安装失败。"
  exit 1
fi
echo "JDK 17 安装成功"

# 安装 Maven 3.8.8
echo "开始安装 Maven 3.8.8..."

# 设置 Maven 下载链接和包名
MAVEN_VERSION="3.8.8"
MAVEN_PACKAGE="apache-maven-${MAVEN_VERSION}-bin.tar.gz"
MAVEN_URL="https://dlcdn.apache.org/maven/maven-3/3.8.8/binaries/${MAVEN_PACKAGE}"
MAVEN_INSTALL_DIR="/opt/maven"

# 下载 Maven
echo "下载 Maven 3.8.8..."
wget -O /tmp/${MAVEN_PACKAGE} ${MAVEN_URL}
if [ $? -ne 0 ]; then
  echo "下载 Maven 3.8.8 失败，请检查 URL 或网络连接。"
  exit 1
fi

# 解压 Maven
echo "解压 Maven 3.8.8..."
tar -zxvf /tmp/${MAVEN_PACKAGE} -C /opt/
if [ $? -ne 0 ]; then
  echo "解压 Maven 3.8.8 失败。"
  exit 1
fi

# 创建 Maven 软链接
echo "创建 Maven 软链接..."
ln -sfn /opt/apache-maven-${MAVEN_VERSION} /opt/maven

# 设置环境变量
echo "设置 Maven 环境变量..."
cat << EOF > /etc/profile.d/maven.sh
export MAVEN_HOME=/opt/maven
export PATH=\$PATH:\$MAVEN_HOME/bin
EOF

# 使环境变量立即生效
source /etc/profile.d/maven.sh

# 验证 Maven 安装
echo "验证 Maven 安装..."
mvn -v
if [ $? -ne 0 ]; then
  echo "Maven 安装失败。"
  exit 1
fi
echo "Maven 3.8.8 安装成功。"

# 安装 Git
echo "安装 Git..."
yum install -y git

# 验证 Git 安装
echo "验证 Git 安装..."
git --version
if [ $? -ne 0 ]; then
  echo "Git 安装失败。"
  exit 1
fi
echo "Git 安装成功。"

# 清理临时文件
echo "清理临时文件..."
rm -f /tmp/${JDK_PACKAGE} /tmp/${MAVEN_PACKAGE}

echo "JDK 17 和 Maven 3.8.8 安装成功。请执行 'source /etc/profile' 或重新登录以使环境变量生效。"
