Template.header.events
  'click .button-register': (e) ->
    e.preventDefault()
    App.registerModal.update($(e.currentTarget).data())

  'click .button-login': (e) ->
    e.preventDefault()
    App.loginModal.update($(e.currentTarget).data())

  'click .button-timeline': (e) ->
    e.preventDefault()
    username = Meteor.user().username
    App.router.navigate("#{username}", trigger: true)

  'click .button-admin': (e) ->
    e.preventDefault()
    App.router.navigate('admin', trigger: true)

  'click .button-front': (e) ->
    e.preventDefault()
    App.router.navigate('', trigger: true)

  'click .button-logout': (e) ->
    e.preventDefault()
    # Track signouts in Mixpanel
    mixpanel.track('logout', username: Meteor.user().username)
    User.logout()
