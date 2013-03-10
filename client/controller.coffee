class Controller extends ReactiveTemplate
  template: Template.controller

  constructor: ->
    super(arguments...)
    # Init application router
    Router.start(this)


Template.controller.rendered = ->
  $content = $(this.firstNode)
  # If controller content hasn't been already injected
  if $content.is(':empty') and @data.name
    $content.append(Meteor.render => Template[@data.name]())
