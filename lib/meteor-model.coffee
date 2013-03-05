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

  @publish: (name) ->
    ###
      Make model data available to client.

      Warning: This is a wildcard implementation, similar to the autopublish
      package and should be customized in subclasses per needs
    ###
    # Feed data from server to client
    if Meteor.isServer
      Meteor.publish name, =>
        return @mongoCollection.find()

    # Subscribe client to server data
    if Meteor.isClient
      Meteor.subscribe(name)

  @allow: ->
    ###
      Add client permissions to model data.

      Warning: Even though this implementation restricts users from messing
      with other users' data, more restrictive permissions might need to be
      implementated in other model subclasses, depending on their sensitivity
      (e.g. shouldn't be publicly readable)

      Note: This assumes a "createdBy" attribute in all documents
    ###
    return unless Meteor.isServer

    @mongoCollection.allow
      insert: (userId, doc) ->
        # Only allow logged in users to create documents
        return false unless userId?
        # Don't allow users to create documents on behalf of other users
        return false if userId isnt doc.createdBy
        return true
      update: (userId, docs) ->
        # Don't allow guests to update anything
        return false unless userId?
        for doc in docs
          # Don't allow users to edit other users' documents
          return false unless userId is doc.createdBy
        return true
      remove: (userId, docs) ->
        # Don't allow guests to remove anything
        return false unless userId?
        for doc in docs
          # Don't allow users to remove other users' documents
          return false unless userId is doc.createdBy
        return true

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
      # Extract _id from model attributes
      data = _.omit(@data, '_id')
      @mongoCollection.update(@data._id, {$set: data}, @saveCallback callback)
    else
      @mongoCollection.insert(@data, @saveCallback callback)

  saveCallback: (userCallback) ->
    # Crate a closure where the user callback is present in the mongo callback
    return (error, id) =>
      if not error? and _.isString(id)
        @update(_id: id)

      if _.isFunction(userCallback)
        userCallback(error?.reason, this)
