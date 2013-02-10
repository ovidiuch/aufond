Controller =
  listeners: {}
  name: 'front'

  createContainer: ->
    ###
      Create radioactive controller container that changes whenever the
      Controller object changes its name, which happens on Router events.
    ###
    container = Meteor.render(=>
      name = @getName()
      return '' unless name
      return Template[name]()
    )
    return container

  getName: ->
    context = Meteor.deps.Context.current
    # If we're inside a context, and it's not yet listening to the controller
    if context and not @listeners[context.id]
      @listeners[context.id] = context
      # Remove context listener when it goes away
      context.onInvalidate =>
        delete @listeners[context.id]
    return @name

  change: (name) ->
    @name = name
    # Notify any contexts that ask about the controller name and remove their
    # listeners
    for id, context of @listeners
      context.invalidate()
