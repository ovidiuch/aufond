class @Controller extends ReactiveTemplate
  template: Template.controller

  events:
    # Alter the global .button event handling and rely on "mouseup" events
    # instead of "click" ones, in order to fix a bug related to intercepting
    # mouse click events https://github.com/skidding/aufond/issues/33
    'mouseup .button': 'onButtonMouseUp'
    'click .button': 'onButtonClick'

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
    # Don't re-render entire admin section when changing tabs, they will be
    # revealed by themselves so there's nothing to do here
    # XXX this breaks Controller's encapsulation
    else if data.name is 'admin' and @data.name is 'admin'
      return
    else
      super(arguments...)

  rendered: (templateInstance) ->
    super(arguments...)
    $content = $(@templateInstance.firstNode)
    # If controller content hasn't been already injected
    if $content.is(':empty') and @data.name
      $content.append(Meteor.render => Template[@data.name]())

  onButtonMouseUp: (e) =>
    # Turn all "mouseup" events into "click" ones
    $(e.currentTarget).click()

  onButtonClick: (e) =>
    # Make sure to ignore "natural" click events and only accept those manually
    # triggered from the "mouseup" handler
    e.stopPropagation() if e.originalEvent?
