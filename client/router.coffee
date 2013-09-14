class @Router extends Backbone.Router

  @start: (controller) ->
    App.router = new this(controller)
    Backbone.history.start(pushState: true)

  constructor: (controller) ->
    super()
    # Keep a local reference to the application controller
    @controller = controller

  routes:
    'admin': 'admin'
    'admin/:tab': 'admin'
    '': 'front'
    'thanks': 'thanks'
    'unsubscribe/:id': 'unsubscribe'
    '*path': 'timeline'

  navigate: (path, options) ->
    super(arguments...)
    if options.resetScroll
      # Ensure scrolling will be on top of the page navigating to
      $('html, body').scrollTop(0)

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

  thanks: ->
    @changeController
      name: 'thanks'

  admin: (tab) ->
    # Make sure admin controller can't be accessed w/out being logged in.
    # Prompt the login modal when trying to do so instead
    unless Meteor.userId()
      @navigate('', trigger: true)
      @promptLoginModal()
    else
      @changeController
        name: 'admin'
        tab: tab or 'entries'

  unsubscribe: (id) ->
    ###
      Link for users to unsubscribe from notifications
    ###
    @changeController
      name: 'unsubscribe'
      id: id

  changeController: (args) ->
    # Keep controller arguments in the router object, since it is globally
    # reachable from anywhere inside the app
    @args = args
    # Update reactive controller with new args (including new controller name)
    @controller.update(args)

  promptLoginModal: ->
    ###
      Open login modal manually, without being triggered by a button click
    ###
    # These attributes would normally come from the data attributes of a button
    # that toggled the modal visible
    App.loginModal.update
      title: 'Good day!'
      button: 'Let me in'
    # The login modal is located in the global index.html template layout so
    # it's accessible from anywhere within the app
    $('#login-modal').modal()
