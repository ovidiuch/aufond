class Form extends ReactiveTemplate

  events:
    'submit form': 'onSubmit'

  constructor: ->
    super(arguments...)

    # Accept an onSuccess callback that overrides what's defined in the
    # prototype for it
    @onSuccess = @params.onSuccess if @params.onSuccess?

  onRender: =>
    # A model id can be passed when instantiating the Form, in order to setup
    # a form instance on a model entry specifically. This model will persist
    # its data inside the form with every re-render (reactive)
    @loadModel(@params.modelId, true, false) if @params.modelId

    return super()

  loadModel: (id, updateParams...) ->
    ###
      Load a model entry and pour its attributes into the module's data set.
      This method receives the model id as the first parameter and then
      implements the same parameters as the ReactiveTemplate.update method,
      which means that the module data cand either be overriden or extended
      and a context change can or can not be triggered
    ###
    # Clear model reference and data before attempting to load a new one
    delete @model
    data = {}

    # A model id is optional at this point, no need for model data when
    # loading a create form for example
    if id
      # It's important to save the model reference at this point, since we'll
      # now know which document to update when submitting the form
      @model = @getModelClass().find(id)
      if @model
        data = @model.toJSON()

    @update(data, updateParams...)

  submit: ->
    data = @getDataFromForm()

    # Add the user id to any model saved inside a form
    data.createdBy = Meteor.userId()

    # Create an empty model instance on create, and only set the data
    # attributes on save in order to be consistent between both methods
    unless @model?
      @model = new (@getModelClass())()

    @model.save data, (error, model) =>
      if error
        @onError(error)
      else if _.isFunction(@onSuccess)
        @onSuccess()

  onSubmit: (e) =>
    e.preventDefault()
    @submit()

  onError: (error) ->
    # Make sure the error is sent to the template, that any success message is
    # cleared, and that the other data attributes are left alone (second param
    # is extend: true)
    @update(
      error: error
      success: ''
    , true)

  getModelClass: ->
    ###
      The model class is passed using its name as a String, in order avoid
      dependency issues since managing the loading order of modules in Meteor
      is pretty limited
    ###
    return window[@params.model]

  getDataFromForm: ->
    return $(@templateInstance.find('form')).serializeObject()
