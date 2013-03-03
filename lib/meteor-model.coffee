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


class MeteorModel
  ###
    XXX document
  ###
  @collection: MeteorCollection

  @get: ->
    models = @mongoCollection.find(arguments...).map (data) =>
      return new this(data)
    return new @collection(models)

  @find: ->
    data = @mongoCollection.findOne(arguments...)
    return false unless _.isObject(data)
    return new this(data)

  @remove: (id) ->
    @mongoCollection.remove(_id: id)

  constructor: (data = {}) ->
    # Keep a reference to the model collection in all instances as well
    @mongoCollection = @constructor.mongoCollection
    @data = {}
    @update data

  update: (data) ->
    _.extend @data, data

  get: (key) ->
    return @data[key]

  set: (key, value) ->
    if _.isObject(key)
      data = key
    else
      data = {}
      data[key] = value
    @update data

  toJSON: ->
    return _.clone @data

  validate: ->
    # XXX make this return a list of errors instead of a string

  save: (data = {}, callback) ->
    # Adding new data along with saving is optional, so the callback may be the
    # only parameter sent
    if _.isFunction(data)
      callback = data
    else
      @update data

    # Validate client-side first and only push to db if passes
    error = @validate()
    if error
      callback(error) if _.isFunction(callback)
      return

    if @data._id
      @mongoCollection.update {_id: @data._id}, @data, @saveCallback(callback)
    else
      @mongoCollection.insert @data, @saveCallback(callback)

  saveCallback: (userCallback) ->
    # Crate a closure where the user callback is present in the mongo callback
    return (error, id) =>
      if not error? and _.isString(id)
        @update(_id: id)

      if _.isFunction(userCallback)
        userCallback(error, this)
