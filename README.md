Installation Guide
======
Tested on Debian 7 (Wheezy)

```bash
# Where the project will be situated
mkdir -p /var/www/aufond

# We need to install Git and fetch the private repo for the install script
aptitude install -y git && git clone https://github.com/skidding/aufond.git /var/www/aufond

# Setup project
cd /var/www/aufond && script/install.sh

# Add cronjob to start project in case it crashes
crontab -e

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
*/1 * * * * /var/www/aufond/script/start.sh
```
