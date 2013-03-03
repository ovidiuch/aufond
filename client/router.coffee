AufondRouter = Backbone.Router.extend
  routes:
    'admin': 'admin'
    '': 'front'
    '*path': 'timeline'

  timeline: (path) ->
    # XXX parse path and get username/post slug
    args =
      path: path
      parts: path.split('/')
    Aufond.controller.change('timeline', args)

  front: ->
    Aufond.controller.change('front')

  admin: ->
    Aufond.controller.change('admin')

Meteor.startup ->
  Aufond.controller = new Controller()
  Aufond.router = new AufondRouter()
  Backbone.history.start(pushState: true)
