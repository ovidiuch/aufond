aufond
===
A résumé for the modern age

### Mission

"An elegant and straightforward way to exhibit your lifelong achievements." — Visit the [app homepage](http://aufond.me) for more product info.

## Structure

Since __[Meteor.js](http://www.meteor.com/)__ provides tight conventions for [structuring your app](http://docs.meteor.com/#structuringyourapp), most of the app is structured the way you'd expect if from a Meteor project.

There are two abstractions that stand out the most:

- [ReactiveTemplate](https://github.com/skidding/aufond/blob/master/client/lib/core/reactive-template.coffee) - Widget-like component that encapsulates the logic related to a template, making use of the reactive programming concept and the powerful [Deps](http://docs.meteor.com/#deps) API
- [MeteorModel](https://github.com/skidding/aufond/blob/master/lib/meteor-model.coffee) - Agnostic model wrapper for the [Meteor.Collections](http://docs.meteor.com/#collections) with a common ORM interface

Also notable is that the entire app is written in CoffeeScript.

### Entry point

The [app router](https://github.com/skidding/aufond/blob/master/client/router.coffee) is built on top of [Backbone.Router](http://backbonejs.org/#Router). It is intertwined with a [global controller](https://github.com/skidding/aufond/blob/master/client/controller.coffee), which manages the changing of one controller (page layout) to another. The entire client app starts when `Router.start()` is [called](https://github.com/skidding/aufond/blob/master/client/controller.coffee#L16), when this global controller is initialized, which happens because of [its placement in the index.html layout.](https://github.com/skidding/aufond/blob/master/client/index.html#L25)

## Installation

### Requirements

- [node.js](http://nodejs.org/) - JS platform on top of which Meteor.js is built
- [Meteor.js](http://docs.meteor.com/) - The framework at the heart of the application
- [PhantomJS](http://phantomjs.org/) - Used to [serve crawlable pages through the Spiderable package](http://www.meteor.com/blog/2012/08/09/search-engine-optimization) and to render static .pdf exports

### Running locally

aufond is as easy to start as any other Meteor app. Just run `meteor` from the repo root.

#### Settings

A JSON settings file can be loaded using the `--settings` option. E.g. `meteor --settings settings.json`

The settings file is not versioned needs to be created, using the [settings.example.json scheleton.](https://github.com/skidding/aufond/blob/90-install-guide/settings.example.json)

### Running in the cloud

Run this on a linux machine, in production environment. — [aufond.me](http://aufond.me) works on Debian 7 (Wheezy)

```bash
# Define the path where the project will be situated
echo "export AUFOND_PATH='/var/www/aufond'" >> ~/.bashrc && source ~/.bashrc

# $AUFOND_PATH will always be defined on this machine, for this user
mkdir -p $AUFOND_PATH && cd $AUFOND_PATH

# Ensure Git is installed and fetch the aufond repo for the install script
aptitude install -y git && git clone https://github.com/skidding/aufond.git .

# Setup project
script/install.sh
```

#### Bundling and starting in production

```bash
# Create Meteor bundle
script/bundle.sh

# Start bundled Meteor app on localhost, port 80. If a process is already
# running on this port, its PID will be displayed instead; this is useful for
# killing that process and restarting the app
script/start.sh

# Start app on a specific port
script/start.sh -p 3000

# Start app for a specific hostname. The hostname is used as the value for the
# ROOT_URL environment variable of Meteor. It's used by the framework to
# generate internal URLs
script/start.sh -h aufond.me

# Specify the Mongo connection (the start script defaults to a guest db hosted
# at MongoHQ)
script/start.sh -m mongodb://guest:aufond1234@paulo.mongohq.com:10016/aufond_guest
```

Don't forget to replicate the settings.json file you're using locally. It will be [picked up and included automatically by the start.sh script,](https://github.com/skidding/aufond/blob/e05ed7287340c1b9c97d226c825b8ed88c70c4ed/script/start.sh#L60) from the root project folder.

### Importing data

There are [a few dumps](https://github.com/skidding/aufond/tree/master/private/mongo-dump) included the project if you want to start off with some data after installing the app. Considering that the local Mongo connection used by Meteor defaults to running on the 3002 port, here is a command line example for quickly importing a user with timeline entries:

```bash
mongoimport -h 127.0.0.1:3002 -d meteor -c users --file private/mongo-dump/sivers.user.json
mongoimport -h 127.0.0.1:3002 -d meteor -c entries --file private/mongo-dump/sivers.entries.json
```

You can now check out [localhost:3000/sivers](http://localhost:3000/sivers) to display the imported data beautifully.

#### Exporting

As a reference, here's how the exporting is done using the opposite Mongo utility, mongoexport:

```bash
mongoexport -h paulo.mongohq.com:10016 -u guest -p aufond1234 -d aufond_guest -c users -q '{username: "sivers"}' -o sivers.user.json
mongoexport -h paulo.mongohq.com:10016 -u guest -p aufond1234 -d aufond_guest -c entries -q '{createdBy: "XDX52YC3jBPmbsiZS"}' -o sivers.entries.json
```

#### Root user

A root user can list all the other users with extended information and can overall do more actions with the help of [a few extra tabs in the admin section.](https://github.com/skidding/aufond/blob/master/client/controller/admin/admin-tabs.html#L6-L10) Making a regular user root is rather manual and requires direct Mongo access. E.g.

```mongo
db.users.update({username:'test'}, {$set: {isRoot: true}})
```

### PhantomJS dry run

aufond uses PhantomJS to generate static exports of your timeline, but you can play with or debug the script manually, from the command line. Note that it has a few [particularities](https://github.com/skidding/aufond/blob/master/server/.phantomjs/export-pdf.js) relevant to the timeline layout.

```bash
phantomjs server/.phantomjs/export-pdf.js http://google.com google.pdf
```
