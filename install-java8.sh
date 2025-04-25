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

# 安装 JDK 8
echo "开始安装 JDK 8..."
# 设置 JDK 下载链接和包名
JDK_URL="https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u402-b06/OpenJDK8U-jdk_x64_linux_hotspot_8u402b06.tar.gz"
JDK_PACKAGE="OpenJDK8U-jdk_x64_linux_hotspot_8u402b06.tar.gz"

# 下载 JDK 8
echo "下载 JDK 8..."
wget -O /tmp/${JDK_PACKAGE} ${JDK_URL}
if [ $? -ne 0 ]; then
  echo "下载 JDK 8 失败，请检查 URL 或网络连接。"
  exit 1
fi

# 解压 JDK
echo "解压 JDK 8..."
tar -zxvf /tmp/${JDK_PACKAGE} -C /usr/local/
if [ $? -ne 0 ]; then
  echo "解压 JDK 8 失败。"
  exit 1
fi

# 重命名解压后的目录为统一名称
# 假设解压后的目录为 `jdk8u402-b06`
mv /usr/local/jdk8u402-b06 /usr/local/jdk8

# 备份现有的 JDK 环境变量文件
if [ -f /etc/profile.d/jdk.sh ]; then
  echo "备份现有的 JDK 环境变量文件..."
  mv /etc/profile.d/jdk.sh /etc/profile.d/jdk17.sh.bak
fi

# 设置环境变量
echo "设置 JDK 8 环境变量..."
cat << EOF > /etc/profile.d/jdk.sh
export JAVA_HOME=/usr/local/jdk8
export PATH=\$JAVA_HOME/bin:\$PATH
EOF

# 使环境变量立即生效
source /etc/profile.d/jdk.sh

# 验证 JDK 安装
echo "验证 JDK 8 安装..."
java -version
if [ $? -ne 0 ]; then
  echo "JDK 8 安装失败。"
  exit 1
fi

echo "JDK 8 安装成功"

# 清理临时文件
echo "清理临时文件..."
rm -f /tmp/${JDK_PACKAGE}

echo "JDK 8 安装成功，JDK 17 环境变量已经停用。"
echo "请执行 'source /etc/profile' 或重新登录以使环境变量生效。"