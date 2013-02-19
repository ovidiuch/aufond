class ReactiveObject
  ###
    Dynamic object that invalidates reactive contexts on demand.

    You can hook up to a reactive context and store its reference internally
    by calling `enableContext` and then invalidate it calling `triggerChange`
  ###
  constructor: ->
    # Don't declare the listeners dict inside the class prototype directly in
    # order to avoid sharing it between all ReactiveObject instances
    @listeners = {}

  enableContext: ->
    ###
      This should be called inside a method called from the reactive context,
      because it pulls out the current context and stores it for future
      invalidating.
    ###
    context = Meteor.deps.Context.current
    # If we're inside a context (that we're not already listening to)
    if context and not @listeners[context.id]
      @listeners[context.id] = context
      # Remove context listener when invalidated. Normally the context will be
      # added again the same way it was added the first time, because this
      # method is called from to the method called inside the context handler,
      # from where it got hooked to it in the first place
      context.onInvalidate =>
        delete @listeners[context.id]

  triggerChange: ->
    ###
      This can be called whenever we consider the reactive object to have
      changed, and want any previously captured contexts to re-run
    ###
    for id, context of @listeners
      context.invalidate()
