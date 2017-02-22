#! /usr/bin/env bash

if [[ "${1}x" == "x" ]] ; then
  echo -e "\nSYNOPSIS"
  echo -e "\tdo-debian-setup.sh [IP_ADDR | HOST_NAME]"
  exit 1
fi

droplet=$1

r() {
    echo "$1"
    ssh root@$droplet "DEBIAN_FRONTEND=noninteractive $1 &>> /var/log/do-debian-setup.txt"
}

l() {
    echo "$1"
    ssh root@$droplet "DEBIAN_FRONTEND=noninteractive $1"
}

r "apt-get install --yes software-properties-common"
r "apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db"
r "add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirror.lstn.net/mariadb/repo/10.1/debian jessie main'"

r "apt-get update"
r "apt-get upgrade --yes"

root_db_pw=$(openssl rand -base64 15)
r "debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password password $root_db_pw'"
r "debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password_again password $root_db_pw'"

r "apt-get install --yes curl git htop vim mariadb-server build-essential"

r "adduser deployer --disabled-password --gecos ''"
r "adduser deployer sudo"
r 'echo "deployer:password" | chpasswd'
r "passwd -e deployer"

deployer_db_pw=$(openssl rand -base64 15)
l "printf '%s\n' '[client]' 'user = root' 'password = $root_db_pw' > .my.cnf"
l "printf '%s\n' '[client]' 'user = deployer' 'password = $deployer_db_pw' > /home/deployer/.my.cnf"
r "mysql -e \"CREATE USER 'deployer'@'localhost' IDENTIFIED BY '$deployer_db_pw';\""
r "mysql -e \"GRANT ALL ON *.* TO 'deployer'@'localhost' IDENTIFIED BY '$deployer_db_pw' WITH GRANT OPTION;\""
r "chown deployer:deployer /home/deployer/.my.cnf"

r "mkdir /home/deployer/.ssh"
r "cp /root/.ssh/authorized_keys /home/deployer/.ssh/"
r "chmod 600 /home/deployer/.ssh/authorized_keys"
r "chown -R deployer:deployer /home/deployer/.ssh"
r "chmod 700 /home/deployer/.ssh"

r "dd if=/dev/zero of=/swapfile bs=1024 count=1024k"
r "chmod 0600 /swapfile"
r "mkswap /swapfile"
r "swapon /swapfile"
l 'echo "/swapfile   none  swap  sw  0   0" >> /etc/fstab'
l "echo 10 > /proc/sys/vm/swappiness"
l 'echo "vm.swappiness = 10" >> /etc/sysctl.conf'
r "chown root:root /swapfile"

l 'echo "/usr/local/lib/x86_64-linux-gnu" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf'
r "ldconfig"
r "wget https://github.com/openssl/openssl/archive/OpenSSL_1_1_0e.tar.gz"
r "tar xf OpenSSL_1_1_0e.tar.gz"
r "cd openssl-OpenSSL_1_1_0e && ./config"
r "cd openssl-OpenSSL_1_1_0e && make"
r "cd openssl-OpenSSL_1_1_0e && make install"

r "git clone https://github.com/andrewhood125/php-7-debian.git"
r "cd php-7-debian && ./build.sh"
r "cd php-7-debian && ./install.sh"
r "sed -i 's/www-data/deployer/g' /usr/local/php7/etc/php-fpm.d/www.conf"

# pcre
r "wget https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.gz"
r "tar xf pcre-8.40.tar.gz"

# zlib
r "wget http://www.zlib.net/zlib-1.2.11.tar.gz"
r "tar xf zlib-1.2.11.tar.gz"

# nginx
r "wget http://nginx.org/download/nginx-1.11.10.tar.gz"
r "tar xf nginx-1.11.10.tar.gz"
r "cd nginx-1.11.10 && ./configure --http-log-path=/var/log/nginx --user=deployer --group=deployer --with-http_ssl_module --with-pcre=../pcre-8.40 --with-zlib=../zlib-1.2.11"
r "cd nginx-1.11.10 && make"
r "cd nginx-1.11.10 && make install"
r "sudo ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin/nginx"

scp nginx.service root@$droplet:/etc/systemd/system/
r "systemctl enable nginx"
r "service nginx start"
r "mkdir -p /etc/nginx/sites-enabled"
r "mkdir -p /etc/nginx/sites-available"
r "rm /usr/local/nginx/conf/nginx.conf"
scp nginx.conf root@$droplet:/usr/local/nginx/conf/
scp default root@$droplet:/etc/nginx/sites-available/

r "wget https://getcomposer.org/installer"
r "php installer --install-dir=/usr/local/bin --filename=composer"

# Install node from binaries because omg it takes forever to build
r "wget https://nodejs.org/dist/v7.5.0/node-v7.5.0-linux-x64.tar.xz"
r "tar xf node-v7.5.0-linux-x64.tar.xz"
r "mv node-v7.5.0-linux-x64 /usr/local/node"
r "ln -s /usr/local/node/bin/node /usr/local/bin/node"
r "ln -s /usr/local/node/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm"

r 'sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config'
r "service ssh reload"

echo -e "\n\tYou may now login to $droplet as deployer"
echo -e "\tyou must set your password on first login.\n"
echo -e "\t\tDefault password is \"password\"\n"
echo -e "\tssh deployer@$droplet"
