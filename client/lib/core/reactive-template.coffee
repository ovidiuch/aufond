class ReactiveTemplate extends ReactiveObject
  ###
    Reactive object subclass that revolves around a template.

    You can create a reactive container by calling createReactiveContainer,
    for which all subclasses need a template name defined using the
    templateName variable. Then, after attaching that container into the
    document, you can call _update_ with new data (optionally) in order to
    trigger a re-rendering of the reactive container.

    See `mapInstance` and `bind` in order to understand how to hook template
    instances to their corresponding reactive template class instances
  ###
  @hookTemplateCallback: (templateName) ->
    ###
      Incercept template callbacks and route them towards a reactive module
      instance if one is found within the template instance data.

      Warning: Since you cannot stack more callbacks of the same type on a
      template, templates used in reactive modules shouldn't have any callbacks
      set directly on them!
    ###
    template = Template[templateName]
    unless template?
      throw new Error "Invalid template name #{templateName}"

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

    # The template name to be loaded reactively can be specified inside the
    # class prototype directly, sent as a param, or even assigned later on
    # into the class instance (before calling createdReactiveContainer, though)
    @templateName = @params.templateName if @params.templateName?
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
    unless @templateName?
      throw new Error "No template name assigned for module"

    # Make sure template has callbacks hooked to reactive modules
    @constructor.hookTemplateCallback(@templateName)

    return Meteor.render =>
      # Hook to context listener and enable reactivity
      @enableContext()

      data = @decorateTemplateData(_.clone(@data))
      return Template[@templateName](data)

  decorateTemplateData: (data) ->
    ###
      Persist base module params along with any data sent to the template.

      This is very importants because we need the module reference to show up
      inside the template instance data along with its callbacks, in order to
      track down its corresponding module instance
    ###
    data.module = this
    return data

  created: (templateInstance) ->
    ###
      _created_ callback of the corresponding template instance.

      Make sure to call super() whenever extending!
    ###
    @templateInstance = templateInstance

  rendered: (templateInstance) ->
    ###
      _rendered_ callback of the corresponding template instance.
    ###

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
  return if $container.children().length

  # Extract module class from template attributes
  unless @data?.module
    throw new Error "Missing module class"
  new @data.module($container, _.omit(@data, 'module'))
