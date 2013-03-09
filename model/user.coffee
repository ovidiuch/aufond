class User extends MeteorModel
  @collection: MeteorCollection
  @mongoCollection: Meteor.users

  @current: ->
    ###
      Static method for fetching current user that can be used globally using
      User.current()
    ###
    userId = Meteor.userId()
    return null unless userId
    return @find(userId)

  @publish: ->
    if Meteor.isServer
      Meteor.publish 'users', =>
        # Only wire the current user to the client
        return @mongoCollection.find(_id: @userId)

      Meteor.publish 'publicUserData', =>
        # Make all usernames and profiles public, matchable by user id
        fields =
          username: 1
          profile: 1
          isRoot: 1
        return @mongoCollection.find({}, {fields: fields})

    if Meteor.isClient
      Meteor.subscribe('users')
      Meteor.subscribe('publicUserData')

  @allow: ->
    ###
      Add client permissions to model data
    ###
    return unless Meteor.isServer

    @mongoCollection.allow
      insert: (userId, doc) ->
        # Allow anybody to create users
        # XXX is there anything to do here to prevent spammers?
        return true
      update: (userId, docs, fields, modifier) ->
        # Don't allow guests to update anything
        return false unless userId?
        for doc in docs
          # Only allow users to update themselves
          return false unless userId is doc._id
          # Only allow profile changes
          return false if _.without(fields, 'profile').length
        return true
      remove: (userId, docs) ->
        # Don't allow guests to remove anything
        return false unless userId?
        for doc in docs
          # Only allow users to delete themselves
          return false unless userId is doc._id
        return true

  mongoInsert: (callback) ->
    ###
      Use Accounts.createUser instead of creating the mongo document manually
    ###
    callback "Can't create users like this!"

  mongoUpdate: (callback) ->
    ###
      Use Accounts.changePassword to change password, instead of editing the
      mongo document manually
    ###
    if @changed.password?
      callback "Can't change password like this!"
    else
      super(callback)

  toJSON: ->
    data = super()
    # Export email address if present
    if data.emails
      data.email = data.emails[0].address
    return data


User.publish();
User.allow();
