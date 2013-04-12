class @Controller extends ReactiveTemplate
  template: Template.controller

  constructor: ->
    super(arguments...)
    # Init application router
    Router.start(this)

  update: (data) ->
    # Load a new slug in a timeline if a new path was targeted within itself,
    # instead of re-rendering the entire template
    # XXX this breaks Controller's encapsulation
    if data.name is 'timeline' and
       data.name is @data.name and
       data.username is @data.username
      Timeline.goTo(data.slug)
    else
      super(arguments...)

Template.controller.rendered = ->
  $content = $(@firstNode)
  # If controller content hasn't been already injected
  if $content.is(':empty') and @data.name
    $content.append(Meteor.render => Template[@data.name]())
