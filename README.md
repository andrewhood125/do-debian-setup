# do-debian-setup
Take a fresh install of Debian on DigitalOcean and spruce it up.  
Althought it could as easily be used for any Debian install.  
  
Output can be found in `/var/log/do-debian-setup.txt`  

What it does
------------
 - Update
 - Upgrade
 - Install `git curl htop vim`
 - Add sudo user `deployer` with password `password`
 - Expire `deployers` password so it must be reset on first login
 - Copy `roots` `authorized_keys` to `deployer`
 - Disables `root` from logging in

Usage
-----
From your development machine run..  
`curl -sS
https://raw.githubusercontent.com/andrewhood125/do-debian-setup/master/do-debian-setup.sh
| bash -s DROPLET_IP_ADDR`
