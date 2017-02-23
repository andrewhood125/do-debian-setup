# do-debian-setup
Take a fresh install of Debian on DigitalOcean and spruce it up.  
Althought it could as easily be used for any Debian install.  
  
Output can be found in `/var/log/do-debian-setup.txt`  

>**Note:** The power of source is time consuming.

What you get
------------
 - Updated
 - Upgraded
 - Handful of helpful utilities `git curl htop vim build-essential certbot`
 - Swap space and updated swap settings better suited for flash storage.
 - MariaDB 10.1
 - OpenSSL 1.1.0e
 - PHP 7.1.2 w/fpm
   - composer
 - Nginx 1.11.10 (Mainline)
 - Node v7.5.0 w/npm
 - Add sudo user `deployer` with password `password`
 - Expire `deployers` password so it must be reset on first login
 - Copy `roots` `authorized_keys` to `deployer`
 - Disables `root` from logging in

Easy SSL with letsencrypt and an A+ rating from SSL Labs. This project is 
inspired by laravel/settler, it aims to provision a droplet for a Laravel 
project like settler does for a vagrant box.

This script can change for the most up-to-date information inspect `./do-debian-setup.sh`.

Usage
-----
From your development machine run..  
`./do-debian-setup.sh` `DROPLET_IP_ADDR`
