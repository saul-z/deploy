# deploy

## ssh配置
```bash
ssh-keygen -t rsa -b 4096 -C "2024.12香港服务器"
cat ~/.ssh/id_rsa.pub
ssh -T git@gitee.com
git clone git@gitee.com:proyunz/deploy.git
```

## 安装java、maven
1.运行install-java-maven.sh

## 部署java应用
1.运行deploy-java.sh
2.防火墙
```bash
sudo firewall-cmd --zone=public --add-port=80/tcp --add-port=3307/tcp --permanent
firewall-cmd --reload
sudo firewall-cmd --list-ports
```



## 安装mysql
1.执行 install-mysql.sh
2.用户远程登陆
```mysql
UPDATE mysql.user SET Host = '%' WHERE User = 'root' AND Host = 'localhost';
FLUSH PRIVILEGES;
```
3.SELinux 机制
vi /etc/selinux/config 设置SELINUX=disabled
setenforce 0
sestatus
4.修改配置文件
vi /etc/my.cnf
port=3307
sudo systemctl restart mysqld
