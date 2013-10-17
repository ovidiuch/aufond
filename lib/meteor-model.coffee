class @MeteorCollection extends Array
  ###
    Wrapper for a list of models. Its only current function is to provide a
    group toJSON method
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
    Agnostic model wrapper for the Meteor.Collections with a common ORM
    interface

    Static methods for selecting or mass updating and deleting: get, find,
    count, remove (mostly aliases for the Meteor.Collection methods
    http://docs.meteor.com/#meteor_collection)

    Meteor methods around the pubsub client-server connection: publish,
    allowInsert, allowUpdate, allowDelete

    Public model methods around a single document: get, set, save, toJSON

    Use the validate method for imposing a (custom) set of requirements for
    input model data, by returning true or false after analysing relevant
    attribute values found in the model at the moment of a save attempt
  ###
  @collection: MeteorCollection

  @get: ->
    ###
      Alias for Meteor.Collection.find http://docs.meteor.com/#find
    ###
    models = @mongoCollection.find(arguments...).map (data) =>
      return new this(data, false)
    return new @collection(models)

  @find: ->
    ###
      Alias for Meteor.Collection.findOne http://docs.meteor.com/#findone
    ###
    data = @mongoCollection.findOne(arguments...)
    return null unless _.isObject(data)
    return new this(data, false)

  @count: ->
    ###
      Wrapper for Meteor.Collection.Cursor.count http://docs.meteor.com/#count,
      with the same method signature as the static `get` method
    ###
    return @mongoCollection.find(arguments...).count()

  @remove: (id, callback) ->
    ###
      Wrapper for Meteor.Collection.remove http://docs.meteor.com/#remove, with
      the document _id to remove as the first parameter, and the callback as
      the second
    ###
    @mongoCollection.remove(_id: id, callback)

  @publish: (subscriptions = {}) ->
    ###
      Make model data available to client.

      The subscriptions parameter is an object with key-value subscriptions,
      with functions attached to subscription names. The function must return
      Meteor.Collection.Cursors (see the Publish and Subscribe concept of
      Meteor http://docs.meteor.com/#publishandsubscribe)

      By sending a string instead of the subscriptions object, a single
      subscription for that name will be created, with all the documents of
      this model. Warning: This is a wildcard implementation, similar to the
      autopublish package
    ###
    if _.isString(subscriptions)
      subscriptionName = subscriptions
      subscriptions = {}
      subscriptions[subscriptionName] = => return @mongoCollection.find()

    if Meteor.isServer
      @setupClientPermissions()

      # Feed data from server to client
      if subscriptions
        for subscriptionName, fn of subscriptions
          Meteor.publish(subscriptionName, fn)

    # Subscribe client to server data
    if Meteor.isClient and subscriptions
      for subscriptionName of subscriptions
        Meteor.subscribe(subscriptionName)

  @setupClientPermissions: ->
    ###
      Warning: Even though this implementation restricts users from messing
      with other users' data, more restrictive permissions might need to be
      implementated in other model subclasses, depending on their sensitivity
      (e.g. some documents should only be created by a class of users)

      Note: The default methods assume a "createdBy" attribute in all documents
    ###
    @mongoCollection.allow
      insert: @allowInsert
      update: @allowUpdate
      remove: @allowRemove

  @allowInsert: (userId, doc) ->
    # Only allow logged in users to create documents
    return false unless userId?
    # Ensure author and timestamp of creation in every document
    doc.createdAt = Date.now()
    doc.createdBy = userId
    return true

  @allowUpdate: (userId, doc, fields, modifier) ->
    # Don't allow guests to update anything
    return false unless userId?
    # Don't allow users to edit other users' documents
    return userId is doc.createdBy

  @allowRemove: (userId, doc) ->
    # Don't allow guests to remove anything
    return false unless userId?
    # The root user can delete any document of any user
    # XXX this is proprietary and should be removed if this components gets
    # separated in any way
    return true if User.find(userId)?.isRoot()
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
    # TODO implement deep copy
    _.extend(@data, @nestAttributes(data))
    # Never mark _id as a changed attribute. Also, mongo supports chained keys
    # so this works out well for the "changed" object and we don't need to nest
    # attributes when populating it
    _.extend(@changed, _.omit(data, '_id'))

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
    # Make deep copy to make sure no data is passed through reference
    return $.extend(true, {}, @data)

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

  destroy: (callback) ->
    @constructor.remove(@get('_id'), callback)

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
