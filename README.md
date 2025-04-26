# deploy

## ssh配置
```bash
ssh-keygen -t rsa -b 4096 -C "2024.12香港服务器"
cat ~/.ssh/id_rsa.pub
ssh-copy-id username@remote_host  #将本地的公钥追加到远程服务器的~/.ssh/authorized_keys文件中
ssh-keyscan example.com #ssh-keyscan 是一个工具，用于从远程主机收集 SSH 公钥（host keys）
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

## 编码问题
设置locale
```
sudo echo 'LANG=en_US.UTF-8' > /etc/locale.conf
sudo echo 'LC_ALL=en_US.UTF-8' >> /etc/locale.conf
```

```
echo "export LANG=en_US.UTF-8" >> ~/.bashrc
source ~/.bashrc
```

## nginx
测试配置 nginx -t
systemctl restart nginx / nginx -s reload

nginx -V 查看编译选项
--prefix=/usr/share/nginx，这意味着默认的HTML目录应该是 /usr/share/nginx/html/
--error-log-path=/var/log/nginx/error.log 

## ssl配置
只安装基本的 certbot
sudo yum -y install certbot

使用 standalone 模式生成证书（记得先停止 nginx）
sudo systemctl stop nginx
sudo certbot certonly --standalone -d yunfire.com -d www.yunfire.com

设置自动续期：
添加一个 cron 任务来自动续期证书（每天尝试一次，但只有在证书快过期时才会真正更新）：
bashecho "0 3 * * * root certbot renew --quiet" | sudo tee -a /etc/crontab


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
5. curl cip.cc  ip地址查询
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

