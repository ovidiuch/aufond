if Meteor.isClient
  Template.hello.greeting = -> return 'Welcome to aufond.'
  Template.hello.events(
    'click input': ->
      # template data, if any, is available in 'this'
      if typeof console isnt 'undefined'
        console.log 'You pressed the button'
  )

  AufondRouter = Backbone.Router.extend
    routes:
      'admin': 'admin'
    admin: ->
      console.log 'This is admin!'

  # On document load
  $(->
    new AufondRouter()
    Backbone.history.start({pushState: true});
  )

if Meteor.isServer
  Meteor.startup(->
    # code to run on server at startup
  )