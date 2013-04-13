class @MeteorCollection extends Array
  ###
    XXX document
  ###
  constructor: (models = []) ->
    for model in models
      @push(model)

  toJSON: (raw = false)->
    models = []
    for model in this
      models.push(model.toJSON(arguments...))
    return models


class @MeteorModel
  ###
    XXX document
  ###
  @collection: MeteorCollection

  @get: ->
    models = @mongoCollection.find(arguments...).map (data) =>
      return new this(data, false)
    return new @collection(models)

  @find: ->
    data = @mongoCollection.findOne(arguments...)
    return null unless _.isObject(data)
    return new this(data, false)

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
        return userId is doc.createdBy
      update: (userId, doc, fields, modifier) ->
        # Don't allow guests to update anything
        return false unless userId?
        # Don't allow users to edit other users' documents
        return userId is doc.createdBy
      remove: (userId, doc) ->
        # Don't allow guests to remove anything
        return false unless userId?
        # Don't allow users to remove other users' documents
        return userId is doc.createdBy

  constructor: (data = {}, isNew = true) ->
    # Keep a reference to the model collection in all instances as well
    @mongoCollection = @constructor.mongoCollection

    # Init attribute holding vars (defined in constructor for the first time
    # and not in prototype so that they don't get mixed up between instances
    # that share the same prototype)
    @data = _.clone(data)
    # Only mark initial data as changed if this model is new (not loaded from
    # a model query, that is)
    @changed = if isNew then _.clone(data) else {}

  update: (data) ->
    ###
      Extend current data object with new attributes.

      Note: Nested attributes can be set using a dot separator (e.g.
      "profile.name")
    ###
    _.extend @data, @nestAttributes(data)
    # Never mark _id as a changed attribute. Also, mongo supports chained keys
    # so this works out well for the "changed" object and we don't need to nest
    # attributes when populating it
    _.extend @changed, _.omit(data, '_id')

  get: (key) ->
    return @data[key]

  set: (key, value) ->
    if _.isObject(key)
      data = key
    else
      data = {}
      data[key] = value
    @update data

  toJSON: (raw = false) ->
    ###
      No extra decorations should be added when "raw" is set to true
    ###
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

    # Branch logic in methods based on action for easy overriding in subclasses
    if @data._id
      @mongoUpdate(callback)
    else
      @mongoInsert(callback)

  destroy: ->
    @constructor.remove(@get('_id'))

  mongoInsert: (callback) ->
    ###
      Called whenever saving a new mongo document
    ###
    @mongoCollection.insert(@changed, @saveCallback callback)

  mongoUpdate: (callback) ->
    ###
      Called whenever saving an existing mongo document
    ###
    @mongoCollection.update(@data._id, {$set: @changed}, @saveCallback callback)

  saveCallback: (userCallback) ->
    # Crate a closure where the user callback is present in the mongo callback
    return (error, id) =>
      if not error? and _.isString(id)
        @update(_id: id)

      if _.isFunction(userCallback)
        userCallback(error?.reason, this)

      # Clear attributes marked as changed after each sync with the server
      @changed = {}

  nestAttributes: (attributes) ->
    ###
        Nest flattened attribute keys into a nested objects.
    ###
    data = {}
    for k, v of attributes
        subset = data
        keys = k.split('.')
        # Navigate through all the extra key parts and attach the value to the
        # narrowest subset formed
        while keys.length > 1
            key = keys.shift()
            # Create subset if this is the first time we get to it
            subset[key] = {} unless subset[key]?
            subset = subset[key]
        subset[keys.shift()] = v
    return data
