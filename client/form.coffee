class Form extends ReactiveTemplate

  constructor: ->
    super(arguments...)
    @collection = @params.collection

  load: (id) ->
    @id = id
    data = {}
    if @id
      # XXX use models and call .toJSON()
      entry = @collection.collection.findOne(_id: @id)
      data = entry if entry?
    @update(data, false)

  submit: (onSuccess) ->
    data = $(@templateInstance.find('form')).serializeObject()
    if @id?
      # XXX use models
      @collection.collection.update({_id: @id}, data)
      onSuccess()
    else
      entry = new @collection(data)
      entry.save {},
        success: (model, response) -> onSuccess()
        error: (model, error) => @update(error: error, true)
