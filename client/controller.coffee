class Controller extends ReactiveObject
  name: null
  args: {}

  createReactiveContainer: ->
    ###
      Create radioactive container that re-renders and triggers a context
      change whenever an internal change is triggered
    ###
    return Meteor.render =>
      @enableContext()
      return @getContents()

  getContents: ->
    name = @getName()
    return '' unless name
    return Template[name]()

  getName: ->
    return @name

  change: (name, args = {}) ->
    @name = name
    @args = args
    @triggerChange()
    # An external onChange handler can be set on the Controller object directly
    @onChange(name, args) if _.isFunction(@onChange)
