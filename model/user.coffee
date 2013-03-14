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
      Meteor.publish 'users', ->
        # Only wire the current user to the client
        return User.mongoCollection.find(_id: @userId)

      Meteor.publish 'publicUserData', ->
        # Make all usernames and profiles public, matchable by user id
        fields =
          username: 1
          profile: 1
          isRoot: 1
        return User.mongoCollection.find({}, {fields: fields})

      Meteor.publish 'userEmails', ->
        # Only make all user emails public to the root user
        return null unless @userId and User.find(@userId).isRoot()
        return User.mongoCollection.find({}, {fields: {emails: 1}})

    if Meteor.isClient
      Meteor.subscribe('users')
      Meteor.subscribe('publicUserData')
      Meteor.subscribe('userEmails')

  @allow: ->
    ###
      Add client permissions to model data
    ###
    return unless Meteor.isServer

    @mongoCollection.allow
      # XXX should remove Filepicker images that became unlinked, in update/
      # remove methods https://github.com/skidding/aufond/issues/16
      insert: (userId, doc) ->
        # Allow anybody to create users
        # XXX is there anything to do here to prevent spammers?
        return true
      update: (userId, doc, fields, modifier) ->
        # Don't allow guests to update anything
        return false unless userId?
        # Only allow users to update themselves
        return false unless userId is doc._id
        # Only allow profile and email changes
        return not _.without(fields, 'profile', 'emails').length
      remove: (userId, doc) =>
        # Don't allow guests to remove anything
        return false unless userId?
        # Get current users
        currentUser = @find(userId)
        if userId is doc._id
          # Never let the root user get deleted, otherwise allow regular users
          # to delete themselves
          return not currentUser.isRoot()
        else
          # Only delete other users w/ root user
          return currentUser.isRoot()

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

  isRoot: ->
    ###
      Helpers method that checks if a user is root
    ###
    return @get('isRoot')


User.publish()
User.allow()
