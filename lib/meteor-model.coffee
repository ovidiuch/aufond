class MeteorModel
  ###
    XXX document
    XXX create get & destroy
  ###
  @find: (id) ->
    data = @collection.findOne _id: id
    return false unless _.isObject(data)
    return new this(data)

  constructor: (data = {}) ->
    # Keep a reference to the model collection in all instances as well
    @collection = @constructor.collection
    @data = {}
    @update data

  get: (key) ->
    return @data[key]

  set: (key, value) ->
    @data[key] = value

  update: (data) ->
    _.extend @data, data

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
      @collection.update {_id: @data._id}, @data, @saveCallback(callback)
    else
      @collection.insert @data, @saveCallback(callback)

  saveCallback: (userCallback) ->
    # Crate a closure where the user callback is present in the mongo callback
    return (error, id) =>
      if not error? and _.isString(id)
        @update(_id: id)

      if _.isFunction(userCallback)
        userCallback(error, this)
