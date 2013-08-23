Package.describe({
  summary: "A Meteor wrapper on top of the cloudfiles Npm module"
});

Package.on_use(function (api) {
  api.use('coffeescript');
  api.add_files('methods.coffee', 'server');
});

Npm.depends({cloudfiles: '0.3.4'});
