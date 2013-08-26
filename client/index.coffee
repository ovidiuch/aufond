# We need a global object to attach main modules to
window.App = {}

Handlebars.registerHelper 'controller', ->
  module: Controller

Handlebars.registerHelper 'registerModal', ->
  module: RegisterModal
  globalReference: 'registerModal'

Handlebars.registerHelper 'loginModal', ->
  module: LoginModal
  globalReference: 'loginModal'

# Store a time offset between the client and the server, in order to have
# correct "time ago" estimations relative to createdAt-like timestamps (which
# are set on the server)
Meteor.call 'serverTime', (err, serverTime) ->
  clientTime = new Date().getTime()
  # This offset is in milliseconds
  App.serverTimeOffset = if serverTime then clientTime - serverTime else 0
