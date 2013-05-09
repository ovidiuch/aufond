#/bin/bash

# Clear previous bundle (if any)
if [ -d "bundle/" ]
then
  rm -r bundle/
fi

# Create bundle
meteor bundle aufond.tgz

# Unzip bundle in bundle/ folder
tar xzf aufond.tgz bundle/

# Fix node fibers package
cd bundle/server
npm uninstall fibers
npm install fibers
cd -
