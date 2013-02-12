AufondRouter = Backbone.Router.extend
  routes:
    '': 'front'
    'admin': 'admin'

  front: ->
    Aufond.controller.change('front')

  admin: ->
    Aufond.controller.change('admin')

Meteor.startup ->
  # Init controller and hook it up to the global object
  controller = new Controller()
  window.Aufond.controller = controller

  # Init app router and add store a reference to its instance inside the
  # controller object
  controller.router = new AufondRouter()
  Backbone.history.start(pushState: true)
