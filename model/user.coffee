class @User extends MeteorModel
  @collection: MeteorCollection
  @mongoCollection: Meteor.users

  @initGuestId: ->
    ###
      Plant a unique id inside a cookie for each visitor, in order to create a
      virtual identity that persists between sessions of guest users. Useful
      for tracking actions of not logged-in users
    ###
    unless $.cookie('guestId')
      $.cookie('guestId', Random.id(), expires: 365)

  @getGuestId: ->
    return $.cookie('guestId')

  @remove: (id, callback, exportToEmail = true) ->
    user = User.find(id)
    return unless user?

    trackAction('user delete', username: user.get('username'))

    # Delete user from database completely
    super id, (error) =>
      callback(arguments...) if _.isFunction(callback)

      # Only continue with logging out if user has been removed successfully
      unless error
        user.exportDataToEmail() if exportToEmail

        # Delete all entries belonging to removing user
        # XXX due to this being an untrusted client context, more than one
        # document can not be removed at a time. Move this to a server method to
        # improve its performance
        entry.destroy() for entry in user.getEntries()

        # Current session has been invalidated at this point if currently
        # logged-in user has removed itself (this is the normal case because
        # only admins can remove other users)
        @logout() if id is Meteor.userId()

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
        return User.mongoCollection.find({_id: @userId},
          # Exclude sensitive data from users altogether
          {fields: {services: 0, isSubscribed: 0}})

      Meteor.publish 'publicUserData', ->
        # Make all usernames and profiles public, matchable by user id
        fields =
          username: 1
          profile: 1
          isRoot: 1
        return User.mongoCollection.find({}, {fields: fields})

      Meteor.publish 'rootUserData', ->
        # Only make sensitive user data available to the root user
        # XXX returning a null value instead of a Mongo cursor does not trigger
        # _allSubscriptionsReady and the spiderable plugin remains hanging.
        # Publish supports returning a list of cursors and returning an empty
        # list seems to hit the spot
        return [] unless @userId and User.find(@userId).isRoot()
        return User.mongoCollection.find({},
          {fields: {emails: 1, isSubscribed: 1}})

    if Meteor.isClient
      Meteor.subscribe('users')
      Meteor.subscribe('publicUserData')
      Meteor.subscribe('rootUserData')

  @allow: ->
    ###
      Add client permissions to model data
    ###
    return unless Meteor.isServer

    @mongoCollection.allow
      # XXX should remove Filepicker images that became unlinked, in update/
      # remove methods https://github.com/skidding/aufond/issues/16
      insert: (userId, doc) ->
        # Users are created using the Accounts.createUser method
        return false
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
      data.profile.hasExtendedContent = Boolean(data.profile.bio or
                                                data.profile.links?.length)
      # Add indices to links in order to make them countable in templates
      if data.profile.links?.length
        for link, i in data.profile.links
          link.index = i
      # Export a count to quickly identify how many entries a user has
      data.entryCount = Entry.count(createdBy: data._id)
    return data

  validate: ->
    if @get('profile').links?.length
      for link in @get('profile').links
        return "Can't add a link w/out an address" unless link.address
        return "Every link needs to have a corresponding icon" unless link.icon

  isRoot: ->
    ###
      Helpers method that checks if a user is root
    ###
    return @get('isRoot')

  hasEmail: (validate = false) ->
    address = @getEmail()
    return false unless address
    return not validate or address.match(/^\S+@\S+\.\S+$/)

  getEmail: ->
    emails = @get('emails')
    return null if _.isEmpty(emails)
    return emails[0].address

  getEmailField: ->
    ###
      Form the richest verson for the To field of an email, by including the
      user's name when existing. Can't form an email field w/out an address
    ###
    address = @getEmail()
    return null unless address
    name = @get('profile').name
    if name
      return "#{@getCleanName()} <#{address}>"
    else
      return address

  getCleanName: ->
    ###
      Strip markdown from name field
      TODO improve once users actually use different markdown tags in their
      name
    ###
    return @get('profile').name?.replace(/^[_\*]{1,2}/, '')
                                .replace(/[_\*]{1,2}$/, '')

  getEntries: (selector = {}, options) ->
    ###
      Proxy for fetching Entry documents, sets the user id selector implicitly,
      but passes any other selector or option through
    ###
    selector = _.extend(createdBy: @get('_id'), selector)
    return Entry.get(selector, options)

  exportDataToEmail: ->
    # No point in exporting the user data if they have no email to send it to
    return unless @hasEmail(true)

    cleanData =
      profile: @toJSON(true).profile
      entries: _.map(@getEntries().toJSON(true), (entry) ->
        # Remove db ids from entry dump
        _.omit(entry, '_id', 'createdBy'))

    # Call server method for sending email
    Meteor.call(
      'sendEmail'
      @getEmail()
      'Ovidiu Cherecheș <contact@aufond.me>'
      "Thank you for using aufond.me—here's your stuff"
      JSON.stringify(cleanData))


User.publish()
User.allow()

if Meteor.isClient
  Meteor.startup ->
    User.initGuestId()

  # Generic callback for having the current user at hand
  Deps.autorun ->
    user = User.current()
    return unless user
    # Track logged in users with an unique handle
    # XXX sometimes mixpanel is not loaded at this point, we should find a
    # better fix than the sanity check, because this way a user might not be
    # tagged at all
    trackUser(user.getEmail() or user.get('username'))

if Meteor.isServer
  Accounts.onCreateUser (options, user) ->
    # Attach the profile to the user document (this happens in the default
    # implementation of the Accounts.onCreateUser that we're overriding)
    if options.profile
      user.profile = options.profile;
    # Automatically subscribe users to aufond.me notifications (no robotic
    # newsletters will ever be sent)
    user.isSubscribed = true
    return user
