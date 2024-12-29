#!/bin/bash

# MySQL 8.4 一键安装及安全配置脚本 for CentOS 7

set -e

# ==========================
# 用户自定义配置部分
# ==========================

# 设置新的 MySQL root 密码
# 请务必将下面的 YOUR_NEW_PASSWORD 替换为您希望设置的强密码
NEW_ROOT_PASSWORD="Mysqlpassword1!"

# ==========================
# 脚本开始
# ==========================

echo "======================================"
echo "   MySQL 8.4 一键安装及安全配置脚本开始运行   "
echo "======================================"

# 检查是否以 root 身份运行
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 用户运行此脚本。"
    exit 1
fi

# 函数：检查并卸载 MariaDB
uninstall_mariadb() {
    echo "检查是否安装了 MariaDB..."
    if rpm -qa | grep -i mariadb > /dev/null 2>&1; then
        echo "检测到 MariaDB 已安装，正在卸载..."
        mariadb_packages=$(rpm -qa | grep -i mariadb)
        for pkg in $mariadb_packages; do
            echo "卸载包：$pkg"
            rpm -e --nodeps "$pkg"
        done
        echo "MariaDB 已成功卸载。"
    else
        echo "未检测到 MariaDB 安装。"
    fi
}

# 函数：安装必要的依赖包
install_dependencies() {
    echo "安装必要的依赖包（libaio, numactl, net-tools, expect）..."
    yum -y install libaio numactl net-tools expect
    echo "依赖包安装完成。"
}

# 函数：下载并安装 MySQL YUM 仓库配置包
setup_mysql_repo() {
    MYSQL_RPM="mysql84-community-release-el7-1.noarch.rpm"
    MYSQL_RPM_URL="https://repo.mysql.com/mysql84-community-release-el7-1.noarch.rpm"

    if [ ! -f "$MYSQL_RPM" ]; then
        echo "下载 MySQL YUM 仓库配置包..."
        wget "$MYSQL_RPM_URL"
    else
        echo "MySQL 仓库配置包已存在，跳过下载。"
    fi

    echo "安装 MySQL YUM 仓库配置包..."

    if rpm -qa | grep -q 'mysql84-community-release-el7-1'; then
        echo "MySQL YUM 仓库配置包已安装，跳过。"
    else
        rpm -Uvh "$MYSQL_RPM" || {
                echo "安装 MySQL 仓库配置包失败。"
                exit 1
            }
    fi
    echo "MySQL 仓库配置完成。"
}

# 函数：清理 YUM 缓存并确认仓库启用
clean_yum_cache() {
    echo "清理 YUM 缓存..."
    yum clean all

    echo "列出已启用的 MySQL 仓库："
    yum repolist enabled | grep mysql
}

# 函数：安装 MySQL 社区服务器
install_mysql_server() {
    echo "安装 MySQL 社区服务器..."
    yum -y install mysql-community-server
    echo "MySQL 社区服务器安装完成。"
}

# 函数：启动并设置 MySQL 服务
start_mysql_service() {
    echo "启用 mysqld 服务开机自启..."
    systemctl enable mysqld

    echo "启动 mysqld 服务..."
    systemctl start mysqld

    echo "检查 mysqld 服务状态..."
    systemctl status mysqld
}

# 函数：获取 MySQL 临时 root 密码
get_temp_password() {
    echo "从日志中获取临时 MySQL root 密码..."
    TEMP_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

    if [ -z "$TEMP_PASSWORD" ]; then
        echo "未能获取到临时密码，请手动检查 /var/log/mysqld.log。"
        exit 1
    else
        echo "临时 MySQL root 密码：$TEMP_PASSWORD"
    fi
}

# 函数：使用 expect 自动化运行 mysql_secure_installation
secure_mysql() {
    echo "开始配置 MySQL 安全设置..."

    expect <<EOF
    set timeout 10
    spawn mysql_secure_installation

    expect "Enter password for user root:"
    send "$TEMP_PASSWORD\r"

    expect "New password:"
    send "$NEW_ROOT_PASSWORD\r"

    expect "Re-enter new password:"
    send "$NEW_ROOT_PASSWORD\r"

    expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
    send "y\r"

    expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
    send "y\r"

    expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
    send "y\r"

    expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
    send "y\r"

    expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
    send "y\r"

    expect eof
EOF

    echo "MySQL 安全配置完成。"
}

# 执行各步骤
uninstall_mariadb
install_dependencies
setup_mysql_repo
clean_yum_cache
install_mysql_server
start_mysql_service
get_temp_password
secure_mysql

echo "======================================"
echo "      MySQL 8.4 安装及安全配置脚本执行完成      "
echo "======================================"
echo "新的 MySQL root 密码已设置为：$NEW_ROOT_PASSWORD"
echo "请妥善保存此密码，并确保其安全。"
