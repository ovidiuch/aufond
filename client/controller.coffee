class @Controller extends ReactiveTemplate
  template: Template.controller

  constructor: ->
    super(arguments...)
    @defaultPageTitle = document.title
    # Init application router
    Router.start(this)

  update: (data) ->
    # Track when changing controller in Mixpanel
    if data.name isnt @data.name
      properties = {}
      if data.name is 'timeline'
        properties.username = data.username
      mixpanel.track("#{data.name}", properties)

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
      # Revert page title to its default value whenever switching between
      # controllers
      document.title = @defaultPageTitle
      super(arguments...)

  rendered: (templateInstance) ->
    super(arguments...)
    $content = $(@templateInstance.firstNode)
    # If controller content hasn't been already injected
    if $content.is(':empty') and @data.name
      $content.append(Meteor.render => Template[@data.name]())
