#! /usr/bin/env bash

if [[ "${1}x" == "x" ]] ; then
  echo -e "\nSYNOPSIS"
  echo -e "\tdo-debian-setup.sh [IP_ADDR | HOST_NAME]"
  exit 1
fi

droplet=$1

r() {
    ssh root@$droplet "DEBIAN_FRONTEND=noninteractive $1 &>> /var/log/do-debian-setup.txt"
}

l() {
    ssh root@$droplet "DEBIAN_FRONTEND=noninteractive $1"
}

echo "Adding mariadb apt repo"
r "apt-get install --yes software-properties-common"
r "apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db"
r "add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirror.lstn.net/mariadb/repo/10.1/debian jessie main'"

echo "Updating..."
r "apt-get update"

echo "Upgrading..."
r "apt-get upgrade --yes"

echo "debconf for mariadb"
db_pw=$(openssl rand -base64 15)
r "debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password password $db_pw'"
r "debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password_again password $db_pw'"

echo "Installing packages..."
r "apt-get install --yes curl git htop vim mariadb-server build-essential nginx"

echo "Adding user deployer..."
r "adduser deployer --disabled-password --gecos ''"
r "adduser deployer sudo"
r 'echo "deployer:password" | chpasswd'
r "passwd -e deployer"

echo "my.cnf"
l "printf '%s\n' '[client]' 'user = root' 'password=$db_pw' > /home/deployer/.my.cnf"

echo "Copying root keys to deployer"
r "mkdir /home/deployer/.ssh"
r "cp /root/.ssh/authorized_keys /home/deployer/.ssh/"
r "chmod 600 /home/deployer/.ssh/authorized_keys"
r "chown -R deployer:deployer /home/deployer/.ssh"
r "chmod 700 /home/deployer/.ssh"

echo "Adding swap..."
r "dd if=/dev/zero of=/swapfile bs=1024 count=1024k"
r "chmod 0600 /swapfile"
r "mkswap /swapfile"
r "swapon /swapfile"
l 'echo "/swapfile   none  swap  sw  0   0" >> /etc/fstab'
l "echo 10 > /proc/sys/vm/swappiness"
l 'echo "vm.swappiness = 10" >> /etc/sysctl.conf'
r "chown root:root /swapfile"

echo "Installing openssl from source"
l 'echo "/usr/local/lib/x86_64-linux-gnu" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf'
r "ldconfig"
r "wget https://github.com/openssl/openssl/archive/OpenSSL_1_1_0e.tar.gz"
r "tar xf OpenSSL_1_1_0e.tar.gz"
r "cd openssl-OpenSSL_1_1_0e && ./config"
r "cd openssl-OpenSSL_1_1_0e && make"
r "cd openssl-OpenSSL_1_1_0e && make install"

echo "Installing php7 from source"
r "git clone https://github.com/andrewhood125/php-7-debian.git"
r "cd php-7-debian && ./build.sh"
r "cd php-7-debian && ./install.sh"

echo "Installing composer"
r "wget https://getcomposer.org/installer"
r "php installer --install-dir=/usr/local/bin --filename=composer"

# Install node from binaries because omg it takes forever to build
r "wget https://nodejs.org/dist/v7.5.0/node-v7.5.0-linux-x64.tar.xz"
r "tar xf node-v7.5.0-linux-x64.tar.xz"
r "mv node-v7.5.0-linux-x64 /usr/local/node"
r "ln -s /usr/local/node/bin/node /usr/local/bin/node"
r "ln -s /usr/local/node/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm"

echo "Disable root login"
r 'sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config'
r "service ssh reload"

echo -e "\n\tYou may now login to $droplet as deployer"
echo -e "\tyou must set your password on first login.\n"
echo -e "\t\tDefault password is \"password\"\n"
echo -e "\tssh deployer@$droplet"
