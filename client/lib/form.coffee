class @Form extends ReactiveTemplate
  # Accepted DOM selector for a submit button
  submitButton: '.button-primary'

  events:
    'focus input, select, textarea': 'onFocus'
    'submit form': 'onSubmit'
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
    @ensureSubmitButton()
    # Only restore previous focus when errors occur
    @restoreFocus() if @data.error

  onSubmit: (e) =>
     e.preventDefault()
     @submit()

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

  ensureSubmitButton: ->
    ###
      HACK a <form> only get submitted by the RETURN key if a submit button is
      present. Since a form can be inside a modal w/ the submit button outside
      itself, or can use a styled anchor to trigger the submit, we need to
      plant an invisible submit button in any form template in order to make
      sure we still trigger the native behavior
    ###
    unless @view.$el.find('[type=submit]').length
      $submitButton = $('<button type="submit"></button>').attr('tabindex', -1)
      # XXX make sure submit button isn't visible and doesn't affect the layout
      # in any way
      $submitButton.css
        position: 'absolute'
        top: -9999
        left: -9999
      # XXX we prepend because input classes might have :last-child styling and
      # having this as the last child would disable it
      @view.$el.find('form').prepend($submitButton)
