AufondRouter = Backbone.Router.extend
  routes:
    'admin': 'admin'
    '*path': 'front'

  front: (path) ->
    # XXX parse path and get user/post slug
    args =
      path: path
    Aufond.controller.change('front', args)

  admin: ->
    Aufond.controller.change('admin')

Meteor.startup ->
  Aufond.controller = new Controller()
  Aufond.router = new AufondRouter()
  Backbone.history.start(pushState: true)
