class Form extends ReactiveTemplate

  constructor: ->
    super(arguments...)
    # The model class is passed using its name as a String, in order avoid
    # dependency issues since managing the loading order of modules in Meteor
    # is pretty limited
    @modelClass = window[@params.model]

  load: (id) ->
    # Clear model reference and data before checking a new one (might not need
    # one at all in case of an add form)
    delete @model
    data = {}

    if id
      @model = @modelClass.find(id)
      data = @model.data if @model?

    @update(data, false)

  submit: (onSuccess) ->
    data = @getDataFromForm()

    # Add the user id to any model saved inside a form
    data.createdBy = Meteor.userId()

    # Create an empty model instance on create, and only set the data
    # attributes on save in order to be consistent between both methods
    @model = new @modelClass() unless @model?
    @model.save data, (error, model) =>
      if error
        @update(error: error, true)
      else
        onSuccess()

  getDataFromForm: ->
    return $(@templateInstance.find('form')).serializeObject()
