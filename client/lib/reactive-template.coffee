class ReactiveTemplate extends ReactiveObject
  ###
    Reactive object subclass that revolves around a template container.

    You can create a reactive container by calling `createReactiveContainer`,
    for which all subclasses need a template name defined using the `template`
    variable. Then, you need to call `update` with new data (optionally) in
    order to trigger a re-rendering of the reactive container.
  ###
  constructor: ->
    super()
    @data = {}

  createReactiveContainer: ->
    ###
      Create radioactive container that re-renders and triggers a context
      change whenever an internal change is triggered
    ###
    return Meteor.render =>
      @enableContext()
      return Template[@template](@data)

  update: (data = {}) ->
    _.extend @data, data
    @triggerChange()
