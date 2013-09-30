#/bin/bash

echo "Installing required packages..."
aptitude install -y curl build-essential libfontconfig1

echo "Installing Node..."
git clone https://github.com/joyent/node.git ~/node && cd ~/node
git checkout v0.10.11
./configure && make && make install
cd -

echo "Installing Meteor..."
curl https://install.meteor.com | /bin/sh

echo "Installing PhantomJS..."
mkdir ~/phantomjs && cd ~/phantomjs
wget https://phantomjs.googlecode.com/files/phantomjs-1.9.1-linux-x86_64.tar.bz2
tar xf phantomjs-1.9.1-linux-x86_64.tar.bz2 --strip-components=1 -C .
cp bin/phantomjs /usr/local/bin/phantomjs
cd -

echo "Installing fonts for .pdf exports..."
mkdir -p /usr/share/fonts/truetype/google-fonts
install -m644 private/font/truetype/google-fonts/* /usr/share/fonts/truetype/google-fonts

echo "App ready to be bundled and started!"
