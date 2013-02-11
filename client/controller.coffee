class Controller extends ReactiveObject
  name: null
  getContents: ->
    name = @getName()
    return '' unless name
    return Template[name]()

  getName: ->
    @enableContext()
    return @name

  change: (name) ->
    @name = name
    @triggerChange()
