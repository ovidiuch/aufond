class @Controller extends ReactiveTemplate
  template: Template.controller

  constructor: ->
    super(arguments...)
    @defaultPageTitle = document.title
    @defaultPageDescription = $('meta[name=description]').prop('content')
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
    if data.name is 'timeline' and
       data.name is @data.name and
       data.username is @data.username
      Timeline.goTo(data.slug)
    # Don't re-render entire admin section when changing tabs, just toggle them
    else if data.name is 'admin' and @data.name is 'admin'
      App.adminTabs.select(App.router.args.tab)
    else
      # Add the controller name as a class on the <body> tag
      $('body').attr('class', data.name)
      # Revert page title and description to their default values whenever
      # switching between controllers
      document.title = @defaultPageTitle
      $('meta[name=description]').prop('content', @defaultPageDescription);
      super(arguments...)

  rendered: (templateInstance) ->
    super(arguments...)
    $content = $(@templateInstance.firstNode)
    # If controller content hasn't been already injected
    if $content.is(':empty') and @data.name
      $content.append(Meteor.render => Template[@data.name]())
