# do-debian-setup
Take a fresh install of Debian on DigitalOcean and spruce it up.
Althought it could as easily be used for any Debian install.

What it does
------------
 - Update
 - Upgrade
 - Install `git curl htop vim`
 - Add user `deployer:password` with sudo
 - Expire deployers password
 - Copy roots authorized keys to deployer

Usage
-----
`curl
https://raw.githubusercontent.com/andrewhood125/do-debian-setup/master/do-debian-setup.sh
| bash -s DROPLET_IP_ADDR`
