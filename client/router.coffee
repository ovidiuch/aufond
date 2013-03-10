class AufondRouter extends Backbone.Router

  @start: (controller) ->
    Aufond.router = new AufondRouter(controller)
    Backbone.history.start(pushState: true)

  constructor: (controller) ->
    super()
    # Keep a local reference to the application controller
    @controller = controller

  routes:
    'admin': 'admin'
    'admin/:tab': 'admin'
    '': 'front'
    '*path': 'timeline'

  timeline: (path) ->
    # Extract username and post slug (optional) from path
    [username, slug] = path.split('/')

    @changeController
      name: 'timeline'
      username: username
      slug: slug

  front: ->
    @changeController
      name: 'front'

  admin: (tab) ->
    @changeController
      name: 'admin'
      tab: tab or 'entries'

  changeController: (args) ->
    # Keep controller arguments in the router object, since it is globally
    # reachable from anywhere inside the app
    @args = args
    # Update reactive controller with new args (including new controller name)
    @controller.update(args)
