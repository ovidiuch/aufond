class ReactiveTemplate extends ReactiveObject
  ###
    Reactive object subclass that revolves around a template container.

    You can create a reactive container by calling `createReactiveContainer`,
    for which all subclasses need a template name defined using the `template`
    variable. Then, you need to call `update` with new data (optionally) in
    order to trigger a re-rendering of the reactive container.

    See `mapInstance` and `bind` in order to understand how to hook template
    instances to their corresponding reactive template class instances
  ###
  @templates: []

  @mapInstance: (reactiveInstance) ->
    ###
      Save a unique reference to a reactive template class instance, in order
      to map its corresponding template instance, later on, when a `rendered`
      callback of the template fires.

      It needs to be called from every instance constructor, sending the
      instance itself as the only parameter
    ###
    id = _.uniqueId() + 1
    # Store template id in class instance as well, in order to send it to the
    # template vars when rendering
    reactiveInstance.templateId = id
    @templates[id] = reactiveInstance

  @bind: (templateInstance) ->
    ###
      After a template instance has enters a `rendered` callback, it should
      call `ReactiveTemplate.bind` in order for it to be bound to its
      corresponding reactive template class instance, with its own reference
      as the only parameter
    ###
    id = $(templateInstance.firstNode).data('template')
    @templates[id]?.templateRendered(templateInstance)

  constructor: ->
    super()
    @data = {}
    @constructor.mapInstance(this)

  createReactiveContainer: ->
    ###
      Create radioactive container that re-renders and triggers a context
      change whenever an internal change is triggered
    ###
    return Meteor.render =>
      # Hook to context listener and enable reactivity
      @enableContext()
      data = _.clone(@data)
      # Send template id if a template instance is hooked to this reactive
      # template class instance
      _.extend(data, templateId: @templateId) if @templateId?
      # XXX it would be cool if we could assign the template id data attribute
      # from here programatically, instead of having to define it in every
      # template file that belongs to a reactive template class
      return Template[@template](data)

  templateRendered: (instance) ->
    ###
      Called every time the corresponding template triggers a `rendered` event
      and gets bounds to its class instance.

      Make sure to call super() whenever extending!
    ###
    @templateInstance = instance

  update: (data = {}, extend = false) ->
    if extend
      _.extend(@data, data)
    else
      @data = _.clone(data)
    # Trigger a context change
    @triggerChange()
