class Modal extends ReactiveObject
  data: {}

  constructor: ($container) ->
    super()
    $container.append(@createContainer())

  createContainer: ->
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
