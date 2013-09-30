aufond
===
A résumé for the modern age

### Mission

"An elegant and straightforward way to exhibit your lifelong achievements." — Visit the [app homepage](http://aufond.me) for more product info.

## Installation

### Requirements

- [node.js](http://nodejs.org/) - JS platform on top of which Meteor.js is built
- [Meteor.js](http://docs.meteor.com/) - The framework at the heart of the application
- [PhantomJS](http://phantomjs.org/) - Used to [serve crawlable pages through the Spiderable package](http://www.meteor.com/blog/2012/08/09/search-engine-optimization) and to render static .pdf Exports

### Running locally

aufond is as easy to start as any other Meteor.js app. Just run `meteor` from the repo root.

### Running in the cloud

Run this on a linux machine, in production environment. — [aufond.me](http://aufond.me) works on Debian 7 (Wheezy)

```bash
# Define the path where the project will be situated
echo "export AUFOND_PATH='/var/www/aufond'" >> ~/.bashrc && source ~/.bashrc

# $AUFOND_PATH will always be defined on this machine, for this user
mkdir -p $AUFOND_PATH && cd $AUFOND_PATH

# We ensure Git in installed and fetch the aufond repo for the install script
aptitude install -y git && git clone https://github.com/skidding/aufond.git .

# Setup project
script/install.sh
```

#### Bundling and starting in production

```bash
# Create Meteor bundle
script/bundle.sh

# Start bundled Meteor app on port 3000. If a process is already running on
# this port, its PID will be displayed instead; this is useful for killing
# that process and restarting the app
script/start.sh 3000
```
