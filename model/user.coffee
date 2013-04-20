class @User extends MeteorModel
  @collection: MeteorCollection
  @mongoCollection: Meteor.users

  @remove: (id, exportToEmail = true) ->
    user = User.find(id)
    return unless user?

    # Gather all entries posted by user
    entries = Entry.get(createdBy: id)

    # Dump entries to email if user has one
    if exportToEmail and user.hasEmail()
      cleanEntries = _.map entries.toJSON(true), (entry) ->
        # Remove db ids from entry dump
        _.omit(entry, '_id', 'createdBy')

      # Call server method for sending email
      Meteor.call(
        'sendEmail'
        user.getEmail()
        'Ovidiu Cherecheș <hello@ovidiu.ch>'
        "Thank you for using Aufond—here's your stuff"
        JSON.stringify(cleanEntries))

    # Delete all entries belonging to removing user
    # XXX due to this being an untrusted client context, more than one
    # document can not be removed at a time. Move this to a server method to
    # improve its performance
    entry.destroy() for entry in entries

    # Delete user from database completely
    super(id)

    # Current session has been invalidated at this point
    @logout()

  @current: ->
    ###
      Static method for fetching current user that can be used globally using
      User.current()
    ###
    userId = Meteor.userId()
    return null unless userId
    return @find(userId)

  @logout: ->
    Meteor.logout (error) ->
      if error
        # XXX handle logout error
      else
        App.router.navigate('', trigger: true)

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

  toJSON: (raw = false) ->
    data = super(arguments...)
    unless raw
      # Export email address if present
      if @hasEmail()
        data.email = @getEmail()
      data.profile.hasExtendedContent = Boolean(data.profile.bio)
      # Add indices to links in order to make them countable in templates
      if data.profile.links?.length
        for link, i in data.profile.links
          link.index = i
    return data

  validate: ->
    if @get('profile').links?.length
      for link in @get('profile').links
        return "Can't add a link w/out a URL" unless link.url
        return "Every link needs to have a corresponding icon" unless link.icon

  isRoot: ->
    ###
      Helpers method that checks if a user is root
    ###
    return @get('isRoot')

  hasEmail: ->
    return @get('emails')?.length > 0

  getEmail: ->
    return @get('emails')?[0].address


User.publish()
User.allow()
