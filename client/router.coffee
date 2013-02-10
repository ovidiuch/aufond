AufondRouter = Backbone.Router.extend
  routes:
    '': 'front'
    'admin': 'admin'

  front: ->
    Controller.change('front')

  admin: ->
    Controller.change('admin')

# Init router and add store instance reference in the controller object
Controller.router = new AufondRouter()
Backbone.history.start(pushState: true)
