#! /usr/bin/env bash

PACKAGES=(curl git htop vim)

if [[ "${1}x" == "x" ]] ; then
  echo -e "\nSYNOPSIS"
  echo -e "\tdo-debian-setup.sh [IP_ADDR | HOST_NAME]"
  exit 1
fi

ssh root@$1 'echo "Updating..." && \
  apt-get update &>> /var/log/do-debian-setup.txt && \
  echo "Upgrading..." && \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y &>> /var/log/do-debian-setup.txt && \
  echo "Installing '"${PACKAGES[@]}"'..." && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y '"${PACKAGES[@]}"' &>> /var/log/do-debian-setup.txt && \
  adduser deployer --disabled-password --gecos "" &>> /var/log/do-debian-setup.txt && \
  adduser deployer sudo &>> /var/log/do-debian-setup.txt && \
  echo "deployer:password" | chpasswd && \
  passwd -e deployer &>> /var/log/do-debian-setup.txt && \
  mkdir /home/deployer/.ssh && \
  cp /root/.ssh/authorized_keys /home/deployer/.ssh/ && \
  chmod 600 /home/deployer/.ssh/authorized_keys && \
  chown -R deployer:deployer /home/deployer/.ssh && \
  chmod 700 /home/deployer/.ssh && \
  sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config && \
  service ssh reload &>> /var/log/do-debian-setup.txt'

if [[ "$?" != "0" ]] ; then
  echo "Something went wrong with the install..."
  echo "You can check the log here:"
  echo -e "\tssh root@$1 'cat /var/log/do-debian-setup.txt'"
  exit 2
fi

echo -e "\n\tYou may now login to $1 as deployer"
echo -e "\tyou must set your password on first login.\n"
echo -e "\t\tDefault password is \"password\"\n"
echo -e "\tssh deployer@$1"
