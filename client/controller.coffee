class Controller extends ReactiveObject
  name: null

  createContainer: ->
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

  change: (name) ->
    @name = name
    @triggerChange()
