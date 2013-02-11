AufondController = new Controller()
AufondRouter = Backbone.Router.extend
  routes:
    '': 'front'
    'admin': 'admin'

  front: ->
    AufondController.change('front')

  admin: ->
    AufondController.change('admin')

# Init router and add store instance reference in the controller object
AufondController.router = new AufondRouter()
Backbone.history.start(pushState: true)
