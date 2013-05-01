class @Controller extends ReactiveTemplate
  template: Template.controller

  events:
    # Alter the global .button event handling and rely on "mouseup" events
    # besides the "click" ones, in order to fix a bug related to intercepting
    # mouse click events https://github.com/skidding/aufond/issues/33
    'mousedown .button': 'onButtonMouseDown'
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

  onButtonMouseDown: (e) =>
    # Mark the beginning of a click
    $(e.currentTarget).data('_pressing', true)

  onButtonMouseUp: (e) =>
    # Wait to see if a click event will follow this one, and similate it in
    # case it doesn't
    window.setTimeout =>
      # Trigger a manual click event if a natural one hasn't by now
      if $(e.currentTarget).data('_pressing')
        @triggerClickEvent(e.currentTarget)

  onButtonClick: (e) =>
    # Flag the button as clicked so the mouseup hack doesn't kick in anomore
    $(e.currentTarget).data('_pressing', false)

  triggerClickEvent: (element) ->
    # XXX IE vs others
    if document.createEventObject
      element.fireEvent('onclick', document.createEventObject())
    else
      e = document.createEvent('HTMLEvents')
      e.initEvent('click', true, true)
      element.dispatchEvent(e)
