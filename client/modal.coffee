class Modal extends ReactiveTemplate
  template: 'modal'

  constructor: (reactiveObject, options = {}) ->
    super()
    @data = {}
    @reactiveObject = reactiveObject
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

  afterRender: ->
    $body = @$container.find('.modal-body')
    # Make sure the reactive body isn't already injected, which also assures
    # that the `render` callback is not called on child renders
    return unless $body.is(':empty')

    $body.append(@reactiveObject.createReactiveContainer())
    @callback('render')

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
  element.data('instance')?.afterRender()
