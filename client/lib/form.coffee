class @Form extends ReactiveTemplate
  # Accepted DOM selector for a submit button
  submitButton: '.button-primary'

  events:
    'focus input, select, textarea': 'onFocus'
    # XXX forms are being submitted inconsistently on RETURN key when not
    # having a submit button inside them, so we need to disable the native
    # behavior and rely solely on custom keyboard and mouse event handlers
    'submit form': (e) -> e.preventDefault()
    'keyup input': 'onKeyUp'
    'click .button': 'onButtonClick'

  constructor: ->
    super(arguments...)
    # A model id can be passed when instantiating the Form, in order to setup
    # a form instance on a model entry specifically. This model will persist
    # its data inside the form with every re-render (reactive)
    @loadModel(@params.modelId) if @params.modelId?
    # Accept an onSuccess callback that overrides what's defined in the
    # prototype for it
    @onSuccess = @params.onSuccess if @params.onSuccess?

  onRender: =>
    ###
      Hook reactive context to the data of a model instance by requesting the
      model inside the render callback
    ###
    data = {}
    # A model id is optional at this point (no need for model data inside a
    # create form for example)
    if @modelId
      # It's important to save a reference to the model instance, since we need
      # to know which document to update when submitting the form
      @model = @getModelClass().find(@modelId)
      # The model instance may or may not have been found, depending on the
      # requested document id
      data = @extractModelData() if @model
    else
      # Clear model reference if a previous instance was loaded in this form
      @model = null

    # Ensure the model attributes inside the template data, but as a base for
    # the current data set and without triggering a context change, since we're
    # already inside a callback of one
    @update(_.extend(data, @data), false, false)
    # Enable context and decorate template data in ReactiveTemplate superclass
    super()

  loadModel: (id) ->
    ###
      Attach a model entry to this form
    ###
    @modelId = id
    # Reset template and trigger a context change in order to make sure the
    # onRender hook gets called and the model data reaches the template
    @update({})

  submit: ->
    # Create an empty model instance on create
    unless @model?
      @model = new (@getModelClass())()
      # Add the user id to any model saved inside a form
      @model.set('createdBy', Meteor.userId())

    # Fetch data from form inputs and update the form instance with it (this
    # updates the model attributes as well)
    data = @getDataFromForm()
    @updateFormData(data)

    @model.save (error, model) =>
      if error
        @onError(error)
      else if _.isFunction(@onSuccess)
        @onSuccess()

  rendered: ->
    super(arguments...)
    # Only restore previous focus when errors occur
    @restoreFocus() if @data.error

  onKeyUp: (e) =>
    # Submit form on RETURN key
    @submit() if e.keyCode is 13

  onButtonClick: (e) =>
    # Ignore buttons that aren't submit-eligible
    if $(e.currentTarget).is(@submitButton)
      e.preventDefault()
      @submit()

  onError: (error) ->
    # Make sure the error is sent to the template, that any success message is
    # cleared, and that the other data attributes are left alone (second param
    # is extend: true)
    @update(error: error, true)

  onFocus: (e) =>
    # Keep track of the last focused input in case we want to restore it after
    # a template re-render. Save "id" attribute and not a reference to the
    # DOM element because the element will change once a re-rendering occurs
    @focusedInput = $(e.currentTarget).attr('id')

  getModelClass: ->
    ###
      The model class is passed using its name as a String, in order avoid
      dependency issues since managing the loading order of modules in Meteor
      is pretty limited
    ###
    return window[@params.model]

  getDataFromForm: ->
    return $(@templateInstance.find('form')).serializeObject()

  extractModelData: ->
    return @model.toJSON()

  updateFormData: (data) ->
    # If there's a model attached to this form, update it and use its exported
    # attribute dump (including whatever decorations the model might provide)
    # for the form data set
    if @model
      @updateModel(data)
      data = @extractModelData()
    # Reset the entire form data but don't trigger any context change (which
    # means the template will not re-render because of this update)
    @update(data, false, false)

  updateModel: (data) ->
    @model.set(data)

  restoreFocus: ->
    ###
      Restore focus on last focused input (focus that was probably lost because
      of a template re-render)
    ###
    if @focusedInput
      @view.$el.find("##{@focusedInput}").focus()
