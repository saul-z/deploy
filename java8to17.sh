#!/bin/bash
# 确保脚本以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请使用 root 权限运行此脚本，例如使用 sudo。"
  exit 1
fi

# 检查 JDK 17 是否存在
if [ ! -d "/usr/local/jdk17" ]; then
  echo "未找到 JDK 17 安装目录，请确认是否已正确安装。"
  exit 1
fi

# 清除所有现有的 JDK 相关环境变量文件
echo "清除所有现有的 JDK 环境变量文件..."
rm -f /etc/profile.d/jdk*.sh

# 创建新的 JDK 17 环境变量文件
echo "创建 JDK 17 环境变量文件..."
cat << EOF > /etc/profile.d/jdk17.sh
export JAVA_HOME=/usr/local/jdk17
export PATH=/usr/local/jdk17/bin:\$PATH
EOF

# 确保文件权限正确
chmod 644 /etc/profile.d/jdk17.sh

echo "JDK 17 环境变量已设置。请执行以下命令使其生效："
echo "source /etc/profile"
echo "然后使用 'java -version' 验证版本。"