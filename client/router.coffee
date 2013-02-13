AufondRouter = Backbone.Router.extend
  routes:
    '': 'front'
    'admin': 'admin'

  front: ->
    Aufond.controller.change('front')

  admin: ->
    Aufond.controller.change('admin')

Meteor.startup ->
  Aufond.controller = new Controller()
  Aufond.router = new AufondRouter()
  Backbone.history.start(pushState: true)
