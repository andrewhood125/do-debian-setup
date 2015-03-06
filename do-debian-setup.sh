#! /usr/bin/env bash

PACKAGES=(curl git htop vim)

if [[ "${1}x" == "x" ]] ; then
  echo -e "\nSYNOPSIS"
  echo -e "\t${BASH_SOURCE} [IP_ADDR | HOST_NAME]"
  exit 1
fi

ssh root@$1 'echo "Updating..." && \
  apt-get update -qq && \
  echo "Upgrading..." && \
  apt-get upgrade -qq -y && \
  echo "Installing '"${PACKAGES[@]}"'..." && \
  apt-get install -qq -y '"${PACKAGES[@]}"' && \
  echo "Setup deployer user..." && \
  adduser deployer --disabled-password --gecos "" && \
  adduser deployer sudo && \
  echo "deployer:password" | chpasswd && \
  passwd -e deployer && \
  mkdir /home/deployer/.ssh && \
  cp /root/.ssh/authorized_keys /home/deployer/.ssh/ && \
  chown -R deployer:deployer /home/deployer/.ssh && \
  chmod 600 /home/deployer/.ssh/authorized_keys && \
  chmod 700 /home/deployer/.ssh'

if [[ "$?" != "0" ]] ; then
  echo "Something went wrong with the install..."
  exit 2
fi


echo -e "\n\tYou may now login to $1 as deployer"
echo -e "\tyou must set your password on first login.\n"
echo -e "\t\tDefault password is \"password\"\n"
echo -e "\tssh deployer@$1"
