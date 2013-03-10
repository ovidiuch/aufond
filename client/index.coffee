# We need a global object to attach main modules to
window.Aufond = Aufond = {}

Template.controller.rendered = ->
  ###
    Append the radioactive controller container when the main layout renders
    for the first time
  ###
  return if @hasContent
  @hasContent = true

  controller = Aufond.controller
  $content = $(this.find '#content')
  $content.append(controller.createReactiveContainer())

  # Set a class with the controller name on the #content element
  setControllerClass = (name) ->
    $content.removeClass().addClass(name)
  # Bind to future controller changes but also to current one
  controller.onChange = setControllerClass
  setControllerClass(controller.name) if controller.name?

Handlebars.registerHelper 'registerModal', ->
  module: RegisterModal

Handlebars.registerHelper 'loginModal', ->
  module: LoginModal
