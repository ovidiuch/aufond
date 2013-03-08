class User extends MeteorModel
  @collection: MeteorCollection
  @mongoCollection: Meteor.users

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


User.publish();
User.allow();
