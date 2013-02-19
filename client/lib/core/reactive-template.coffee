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


Handlebars.registerHelper 'reactive', (module, params) ->
  ###
    Global Handlebars helper for rendering a reactive template.

    The module represents the name of a valid ReactiveTemplate subclass. The
    second parameter is reserved for module params, but is optional and the
    Handlebars options might take their place
  ###
  params = if arguments.length > 2 then params else {}

  unless window[module]?
      throw new Error "Invalid module name #{module}"

  # XXX since we cannot append a reactive container in place from a helper
  # response, we need to create an actual DOM element, inject it inside the
  # document body and then append our container inside it. We can't do this
  # synchronously because in order to inject it we need to return a value to
  # this function, which would end its execution. So we create an async
  # callback that will run at the next execution tick, that fetches the
  # returned element from the document DOM (at which point it will be injected)
  # and through an ID reference passed along with it initially, map it to the
  # module instance and use it as a container for the reactive template
  id = _.uniqueId() + 1
  setTimeout -> new window[module]($("[data-template=#{id}]"), params)
  return "<div class=reactive-template data-template=#{id}></div>"
