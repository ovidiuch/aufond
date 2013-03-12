class Form extends ReactiveTemplate

  events:
    'submit form': 'onSubmit'

  constructor: ->
    super(arguments...)

    # A model id can be passed when instantiating the Form, in order to setup
    # a form instance on a model entry specifically. This model will persist
    # its data inside the form with every re-render (reactive)
    @load(@params.modelId) if @params.modelId

    # Accept an onSuccess callback that overrides what's defined in the
    # prototype for it
    @onSuccess = @params.onSuccess if @params.onSuccess?

  load: (id) ->
    # Clear model reference and data before checking a new one (might not need
    # one at all in case of an add form)
    delete @model
    data = {}

    if id
      @model = @getModelClass().find(id)
      data = @model.toJSON() if @model?

    @update(data, false)

  submit: ->
    data = @getDataFromForm()

    # Add the user id to any model saved inside a form
    data.createdBy = Meteor.userId()

    # Create an empty model instance on create, and only set the data
    # attributes on save in order to be consistent between both methods
    @model = new (@getModelClass())() unless @model?
    @model.save data, (error, model) =>
      if error
        @update(error: error, true)
      else if _.isFunction(@onSuccess)
        @onSuccess()

  onSubmit: (e) =>
    e.preventDefault()
    @submit()

  getModelClass: ->
    ###
      The model class is passed using its name as a String, in order avoid
      dependency issues since managing the loading order of modules in Meteor
      is pretty limited
    ###
    return window[@params.model]

  getDataFromForm: ->
    return $(@templateInstance.find('form')).serializeObject()
