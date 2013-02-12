class Modal extends ReactiveObject
  data: {}

  attach: (container) ->
    ###
      Attach modal to a DOM element. It will be ignored if called more than one
      time with the same container element
    ###
    return if container.is(@container)
    @container = container
    @container.append(@createReactiveContainer())

  createReactiveContainer: ->
    ###
      Create radioactive container that re-renders and triggers a context
      change whenever an internal change is triggered
    ###
    return Meteor.render =>
      @enableContext()
      return Template.modal(@data)

  update: (data) ->
    _.extend @data, data
    @triggerChange()
