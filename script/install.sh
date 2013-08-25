#/bin/bash

echo "Setting up user SSH key..."
mkdir -p ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2fDBGRaDOXvGGbUCuAE6GVMI2Aj/FS5RxvYv9uOATkV1dD/EU/3y3q0KXQgGpz6FX/GqGr4S9QdqQFvy1/9I9sZxkNK23+snTSKz9Nr3Q1Vtp0e0lKp8FIdz5XM5k58EpEiW28JJW8Vpsym8KtzbCH3LIsE78zB2Uql0mlRXQFIfm9iE6U08JhCUs+OgCf9PiCD1faSxgSOF67pMsAIVS55SmBPPQNsSa2kvWMrReNgRMaIsCkwLAmMC1gd/JO2EQaS0W2sZ3SK+FxAYcLph/9MMmn1Guly9iGuUHmf0pAk0dMLo1k6a+tBVgAF3I5kTdhLQ6aBa/Pp+elJ2rO5lr ovidiu@Ovidius-MacBook-Air.local" >> ~/.ssh/authorized_keys

echo "Setting up .bashrc startup commands for user..."
echo "export EDITOR=vim" >> ~/.bashrc
echo "cd /var/www/aufond" >> ~/.bashrc

echo "Installing required packages..."
aptitude install -y vim curl build-essential libfontconfig1

echo "Installing Node..."
git clone https://github.com/joyent/node.git /var/www/node
cd /var/www/node
git checkout v0.10.11
./configure && make && make install
cd -

echo "Installing Meteor..."
curl https://install.meteor.com | /bin/sh

echo "Installing PhantomJS..."
mkdir /var/www/phantomjs && cd /var/www/phantomjs
wget https://phantomjs.googlecode.com/files/phantomjs-1.9.1-linux-x86_64.tar.bz2
tar xf phantomjs-1.9.1-linux-x86_64.tar.bz2 --strip-components=1 -C .
cp bin/phantomjs /usr/local/bin/phantomjs
cd -

echo "Installing fonts..."
mkdir -p /usr/share/fonts/truetype/google-fonts
install -m644 private/font/truetype/google-fonts/* /usr/share/fonts/truetype/google-fonts
# Clear font cache
fc-cache -f

echo "Creating initial bundle..."
script/bundle.sh

echo "Project ready! Run script/start.sh to start it."
# Prepare vim editor for setting up cron w/out having to log out and in again
export EDITOR=vim
