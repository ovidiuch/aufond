class @Export extends MeteorModel
  ###
    Static export of a User timeline

    Caracteristics of a timeline export
    - An export mustn't have any external dependencies (aka work offline)
    - An export must be static (not served through any routing system)
    - A user can only export its own timeline
    - An export must be created through server methods, in order to be able to
    implement frequency limits and avoid other exploits
    - An export is generated asynchronously and this model reflects its
    reference and progress status

    TODO remove all static assets (both local and from CDN) when destroying an
    export document
  ###
  @mongoCollection: new Meteor.Collection 'exports'

  @isUserAllowed: (userId) ->
    ###
      Check if a user is allowed to create another export or they just created
      another one too recently
      XXX a way to bypass this would be to keep removing and creating exports
    ###
    # Allow users to create another Export after one minute
    return @secondsSinceLastExport(userId) > 60

  @secondsSinceLastExport: (userId) ->
    ###
      Get the number of seconds that passed since the newest created export
      of a user. The number of seconds since 1970 will be returned if the user
      has no export
    ###
    lastEntry = Export.find({createdBy: userId}, {sort: {createdAt: -1}})
    timeOfLastEntry = lastEntry?.get('createdAt') or 0
    return Math.round((Date.now() - timeOfLastEntry) / 1000)

  @remove: (id, callback) ->
    # Export removal is handled on the server side because files need to be
    # cleaned up and it's safer this way
    Meteor.call('removeExport', id)
    # XXX this means the callback always returns success
    callback() if _.isFunction(callback)

  @allow: ->
    return unless Meteor.isServer
    @mongoCollection.allow
      insert: (userId, doc) ->
        # Only allow logged in users to create documents
        return false unless userId?
        # Don't allow users to create documents on behalf of other users
        return false unless userId is doc.createdBy
        # Prevent users from creating exports too often in order to improve the
        # server's global performance
        return Export.isUserAllowed(userId)
      update: (userId, doc, fields, modifier) ->
        # Don't allow users to alter exports (they can only be altered through
        # server methods)
        return false
      remove: (userId, doc) ->
        # Don't allow guests to remove anything
        return false unless userId?
        # The root user can delete any document of any user
        return true if User.find(userId)?.isRoot()
        # Don't allow users to remove other users' documents
        return userId is doc.createdBy

  constructor: (data = {}, isNew = true) ->
    super(arguments...)
    if isNew
      @update
        # Provide a default status message
        status: 'Pending...'

  toJSON: (raw = false) ->
    data = super(arguments...)
    unless raw
      data.hasError = @hasError()
    return data

  validate: ->
    # Make sure to only apply this on create
    unless @get('_id')
      # Provide this validation in client side as well in order to have instant
      # feedback and a custom message
      userId = Meteor.userId()
      if not Export.isUserAllowed(userId)
        secondsAgo = Export.secondsSinceLastExport(userId)
        return "__Give it a minute...__ literally, you just created an " +
               "export #{secondsAgo} seconds ago"

  mongoInsert: (callback) ->
    super (error, model) ->
      callback(arguments...) if _.isFunction(callback)
      unless error?
        # Start generating timeline export if the model was saved successfully
        Meteor.call('generateExport', model.get('_id'))

  hasError: ->
    ###
      Test if this Export has an error status
    ###
    return Boolean(@get('status').match(/^Error/))

  getUser: ->
    ###
      Proxy for fetching the User document of the Export author
    ###
    return User.find(@get('createdBy'))

  getUsername: ->
    ###
      Proxy for fetching the username of the Export author
    ###
    return @getUser().get('username')


Export.publish('exports')
Export.allow()
