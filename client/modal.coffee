class Modal extends ReactiveObject

  constructor: (options = {}) ->
    super()
    @data = {}
    @callbacks =
      render: options.onRender
      submit: options.onSubmit

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

  callback: (type) ->
    callback = @callbacks[type]
    if _.isFunction(callback)
      # Call the modal callback with itself as a parameter, in order not to
      # depend on any scope, since the callback could be CoffeeScript wrapped
      callback.call(this, this)

Template.modal.events
  'click .btn-primary': (e) ->
    ###
      Call the submit callback of a modal instance if a reference to it is
      found within the data of the container model element
    ###
    element = $(e.currentTarget).closest('.modal')
    element.data('instance')?.callback('submit')

Template.modal.rendered = ->
  ###
    Call the render callback of a modal instance if a reference to it is found
    within the data of the container model element
  ###
  element = $(this.firstNode).closest('.modal')
  element.data('instance')?.callback('render')
