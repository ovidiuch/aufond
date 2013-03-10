class ReactiveTemplate extends ReactiveObject
  ###
    Reactive object subclass that revolves around a template.

    You can create a reactive container by calling createReactiveContainer,
    for which all subclasses need a template assigned using the "template"
    variable. Then, after attaching that container into the document, you can
    call _update_ with new data (optionally) in order to trigger a re-rendering
    of the reactive container.

    See `mapInstance` and `bind` in order to understand how to hook template
    instances to their corresponding reactive template class instances
  ###
  @hookTemplateCallback: (template) ->
    ###
      Incercept template callbacks and route them towards a reactive module
      instance if one is found within the template instance data.

      Warning: Since you cannot stack more callbacks of the same type on a
      template, templates used in reactive modules shouldn't have any callbacks
      set directly on them!
    ###
    for method in ['created', 'rendered', 'destroyed']
      # Don't override already defined callbacks
      continue if template[method]?
      do (method) ->
        template[method] = ->
          ReactiveTemplate.forwardTemplateCallback(this, method)

  @forwardTemplateCallback: (templateInstance, method) ->
    ###
      Forward template callback to module instance.

      It's essential to forward the _created_ callback in order to bind the
      template instance to its respective module
    ###
    module = templateInstance.data.module
    return unless module instanceof ReactiveTemplate

    unless _.isFunction(module[method])
      throw new Error "Invalid module method #{method}"
    module[method](templateInstance)

  constructor: ($container, params = {}) ->
    ###
      Create ReactiveTemplate instance with an optional container and a set of
      params.

      If the module has a designated DOM container it will automatically create
      and inject the reactive template container inside it
    ###
    # Apply the ReactiveObject constructor
    super()

    unless $container instanceof jQuery
      @params = $container or {}
    else
      @params = params
      @$container = $container

    # The template to be loaded reactively can be specified inside the class
    # prototype directly, sent as a param, or even assigned later on into the
    # class instance (before calling createdReactiveContainer, though)
    @template = @params.template if @params.template?
    # Init the template data
    @data = {}

    # Create and append reactive template container in the presence of a DOM
    # element container
    @$container?.append(@createReactiveContainer())

  createReactiveContainer: ->
    ###
      Create radioactive container that re-renders and triggers a context
      change whenever an internal change is triggered
    ###
    unless @template?
      throw new Error "No template assigned for module"

    # Make sure template has callbacks hooked to reactive modules
    @constructor.hookTemplateCallback(@template)

    return Meteor.render =>
      # Hook to context listener and enable reactivity
      @enableContext()

      data = @decorateTemplateData(_.clone(@data))
      return @template(data)

  decorateTemplateData: (data) ->
    ###
      Persist base module params along with any data sent to the template.

      This is very importants because we need the module reference to show up
      inside the template instance data along with its callbacks, in order to
      track down its corresponding module instance
    ###
    data.module = this
    return data

  setupBackboneView: (templateInstance) ->
    ###
      Setup a Backbone View around a the newly (re-)rendered template instance.

      The ReactiveTemplate events object will be passed on to the created View,
      with all its listeners pointing to methods from the ReactiveTemplate
      class instance, and not that of the Backbone View (which is invisible to
      the user, and gets set up in the background)
    ###
    $container = $(templateInstance.firstNode).parent()
    # Create view when not already created or when the current one is attached
    # to previous template instance
    if not @view or not $container.is(@view.el)
      # Garbage collect previous view instance, if any
      @view?.remove()
      @view = new Backbone.View(el: $container)
      @view.delegateEvents(@translateEventListeners())

  translateEventListeners: ->
    ###
      Translate all event listener names form an events object set up on a
      ReactiveTemplate instance to corresponding methods from that instance
    ###
    events = {}
    for event, listener of @events
      if not _.isFunction(this[listener])
        throw new Error "Class has no event listener named #{listener}"
      events[event] = this[listener]
    return events

  created: (templateInstance) ->
    ###
      _created_ callback of the corresponding template instance.

      Make sure to call super() whenever extending!
    ###
    @templateInstance = templateInstance

  rendered: (templateInstance) ->
    ###
      _rendered_ callback of the corresponding template instance.

      Make sure to call super() whenever extending!
    ###
    @setupBackboneView(templateInstance)

  destroyed: (templateInstance) ->
    ###
      _destroyed_ callback of the corresponding template instance.
    ###

  update: (data = {}, extend = false) ->
    ###
      Update the template-designated data and trigger a context change, forcing
      the reactive template to re-render.

      The data can be extended or completely overriden, depending on the state
      of the 2nd parameter
    ###
    if extend
      _.extend(@data, data)
    else
      @data = _.clone(data)

    # Trigger the context change
    @triggerChange()


Template.reactive.rendered = ->
  ###
    Init a ReactiveTemplate once its wrapper template renders
  ###
  $container = $(@firstNode)
  # Check if template wasn't already rendered
  return unless $container.is(':empty')

  # Extract module class from template attributes
  unless @data?.module
    throw new Error "Missing module class"
  new @data.module($container, _.omit(@data, 'module'))
