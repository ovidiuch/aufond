# We need a global object to attach main modules to
window.App = {}

Handlebars.registerHelper 'controller', ->
  module: Controller

Handlebars.registerHelper 'registerModal', ->
  module: RegisterModal

Handlebars.registerHelper 'loginModal', ->
  module: LoginModal


# XXX there must be a better way to check if the user is logged in
Meteor.startup ->
  Deps.autorun ->
    # Track logged in users with an unique handle
    user = User.current()
    if user
      mixpanel.name_tag(user.getEmail() or user.get('username'))
