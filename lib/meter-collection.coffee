class MeteorCollection extends Array
  ###
    XXX document
  ###
  constructor: (models = []) ->
    for model in models
      @push(model)

  toJSON: ->
    models = []
    for model in this
      models.push(model.toJSON())
    return models
