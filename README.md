# deploy

## ssh配置
```bash
ssh-keygen -t rsa -b 4096 -C "2024.12香港服务器"
cat ~/.ssh/id_rsa.pub
ssh -T git@gitee.com
git clone git@github.com:saul-z/deploy.git
```

## 镜像源
阿里镜像：https://developer.aliyun.com/mirror/
```bash
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo

yum clean all

yum makecache
```

## 安装java、maven
1.运行脚本
./install-java-maven.sh

## 部署java应用
1.运行脚本
./deploy-java.sh
2.防火墙
```bash
sudo firewall-cmd --zone=public --add-port=80/tcp --add-port=3307/tcp --permanent
firewall-cmd --reload
sudo firewall-cmd --list-ports
```



## 安装mysql
1.运行脚本
./install-mysql.sh
2.用户远程登陆
```mysql
UPDATE mysql.user SET Host = '%' WHERE User = 'root' AND Host = 'localhost';
FLUSH PRIVILEGES;
```
3.SELinux 机制
```bash
vi /etc/selinux/config 设置SELINUX=disabled
setenforce 0
sestatus
```

4.修改配置文件
```bash
vi /etc/my.cnf
port=3307
sudo systemctl restart mysqld
```

## 运维
1. df -h;free -h;
2. ps -ef | grep java
3. kill pid
4. mysql修改密码
停止MySQL服务
sudo /usr/local/mysql/support-files/mysql.server stop
以跳过授权认证模式登录MySQL
sudo /usr/local/mysql/bin/mysqld_safe --skip-grant-tables &
重置密码
mysql -u root
use mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new password';
FLUSH PRIVILEGES;
重启MySQL服务
sudo /usr/local/mysql/support-files/mysql.server start

