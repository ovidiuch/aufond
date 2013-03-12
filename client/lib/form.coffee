class Form extends ReactiveTemplate

  events:
    'submit form': 'onSubmit'

  constructor: ->
    super(arguments...)

    # Accept an onSuccess callback that overrides what's defined in the
    # prototype for it
    @onSuccess = @params.onSuccess if @params.onSuccess?

  decorateTemplateData: (data) ->
    data = super(data)

    # A model id can be passed when instantiating the Form, in order to setup
    # a form instance on a model entry specifically. This model will persist
    # its data inside the form with every re-render (reactive)
    if @params.modelId
      # If the required model instance is found, extend the current data out
      # of it; meaning that the model data provides a base data set, over which
      # the module data attributes receive precedence
      model = @getModel(@params.modelId)
      if model
        data = _.extend(model.toJSON(), data)

    return data

  load: (id) ->
    # Clear model reference and data before checking a new one (might not need
    # one at all in case of an add form)
    delete @model
    data = {}

    # A model id is optional at this point, no need for one when loading a
    # create form for example
    if id
      # It's useful to save the model reference at this point, since we'll now
      # know which document to update when submitting the form
      @model = @getModel(id)
      data = @model.toJSON() if @model?

    @update(data, false)

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
        @update(error: error, true)
      else if _.isFunction(@onSuccess)
        @onSuccess()

  onSubmit: (e) =>
    e.preventDefault()
    @submit()

  getModel: (id) ->
    ###
      Try to fetch a document wrapped around its relevent model class
    ###
    return @getModelClass().find(id)

  getModelClass: ->
    ###
      The model class is passed using its name as a String, in order avoid
      dependency issues since managing the loading order of modules in Meteor
      is pretty limited
    ###
    return window[@params.model]

  getDataFromForm: ->
    return $(@templateInstance.find('form')).serializeObject()
