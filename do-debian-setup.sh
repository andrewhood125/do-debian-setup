#! /usr/bin/env bash

PACKAGES=(curl git htop vim)

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

echo "Updating..."
r "apt-get update"

echo "Upgrading..."
r "apt-get upgrade --yes"

echo "Installing ${PACKAGES[@]}"
r "apt-get install --yes ${PACKAGES[@]}"

echo "Adding user deployer..."
r "adduser deployer --disabled-password --gecos ''"
r "adduser deployer sudo"
r 'echo "deployer:password" | chpasswd'
r "passwd -e deployer"

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

echo "Disable root login"
r 'sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config'
r "service ssh reload"

echo -e "\n\tYou may now login to $droplet as deployer"
echo -e "\tyou must set your password on first login.\n"
echo -e "\t\tDefault password is \"password\"\n"
echo -e "\tssh deployer@$droplet"
