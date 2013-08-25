#/bin/bash

# Create bundle
echo "Creating Meteor bundle file..."
meteor bundle aufond.tgz

# Clear previous bundle (if any)
if [ -d ".bundle" ]
then
  echo "Removing previous .bundle..."
  rm -r .bundle/*
else
  echo "Creating .bundle folder..."
  mkdir .bundle
fi

# Unzip bundle in .bundle/ folder
# --strip-components removes root "bundle" folder from archive
# -C dumps it into a different folder than the current one
echo "Unzipping bundle in .bundle folder..."
tar xzf aufond.tgz --strip-components=1 -C .bundle

# Fix node fibers package
echo "Re-install fibers package in .bundle folder..."
cd .bundle/programs/server/node_modules
npm uninstall fibers
npm install fibers@1.0.1
cd -
