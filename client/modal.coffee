class Modal extends ReactiveObject
  data: {}

  constructor: (callback) ->
    super()
    @callback = callback

  attach: ($container) ->
    ###
      Attach modal to a DOM element. It will be ignored if called more than one
      time with the same container element
    ###
    return if $container.is(@$container)
    @$container = $container
    # Store a reference to the modal instance inside the element
    @$container.data('instance', this)
    @$container.append(@createReactiveContainer())

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

  close: ->
    @$container.modal('hide')

Template.modal.events
  'click .btn-primary': (e) ->
    ###
      Call the callback of a modal instance if a reference of it is found
      within the data of the container model element
    ###
    element = $(e.currentTarget).closest('.modal')
    instance = element.data('instance')
    if instance? and _.isFunction(instance.callback)
      # Call the modal callback with itself as a parameter, in order not to
      # depend on any scope, since the callback could be CoffeeScript wrapped
      instance.callback(instance)
