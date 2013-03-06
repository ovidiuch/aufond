AufondRouter = Backbone.Router.extend
  routes:
    'admin': 'admin'
    '': 'front'
    '*path': 'timeline'

  timeline: (path) ->
    # Extract username and post slug (optional) from path
    [username, slug] = path.split('/')
    args =
      path: path
      username: username
      slug: slug
    Aufond.controller.change('timeline', args)

  front: ->
    Aufond.controller.change('front')

  admin: ->
    Aufond.controller.change('admin')

Meteor.startup ->
  Aufond.controller = new Controller()
  Aufond.router = new AufondRouter()
  Backbone.history.start(pushState: true)
