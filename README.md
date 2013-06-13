Installation Guide
======
For Debian 7 (Wheezy)

```bash
# Setup user
useradd -m -s /bin/bash skidding
passwd skidding
apt-get -y install sudo
apt-get -y install vim
export EDITOR=vim
visudo
skidding ALL=(ALL) ALL
su skidding
mkdir ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2fDBGRaDOXvGGbUCuAE6GVMI2Aj/FS5RxvYv9uOATkV1dD/EU/3y3q0KXQgGpz6FX/GqGr4S9QdqQFvy1/9I9sZxkNK23+snTSKz9Nr3Q1Vtp0e0lKp8FIdz5XM5k58EpEiW28JJW8Vpsym8KtzbCH3LIsE78zB2Uql0mlRXQFIfm9iE6U08JhCUs+OgCf9PiCD1faSxgSOF67pMsAIVS55SmBPPQNsSa2kvWMrReNgRMaIsCkwLAmMC1gd/JO2EQaS0W2sZ3SK+FxAYcLph/9MMmn1Guly9iGuUHmf0pAk0dMLo1k6a+tBVgAF3I5kTdhLQ6aBa/Pp+elJ2rO5lr ovidiu@Ovidius-MacBook-Air.local" >> ~/.ssh/authorized_keys

# Setup project
sudo mkdir /var/www
sudo chown skidding:skidding /var/www
sudo apt-get -y install git
sudo apt-get -y install build-essential
sudo apt-get -y install curl
cd /var/www
git clone https://github.com/joyent/node.git
cd node
./configure && make && sudo make install
cd /var/www
git clone https://github.com/skidding/aufond.git
curl https://install.meteor.com | /bin/sh
cd aufond
script/bundle.sh
script/start.sh

# Set vim as permanent user editor
vim ~/.bashrc
export EDITOR=vim

# Add cronjob to start project in case it crashes
crontab -e
*/1 * * * * /var/www/aufond/script/start.sh

# Set project path the default login path of the user
vim ~/.bashrc
cd /var/www/aufond
```
