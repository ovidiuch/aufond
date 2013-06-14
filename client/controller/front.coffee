Template.front.events
  'click .button-register': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.registerModal.update(data)

  'click .button-login': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.loginModal.update(data)

  'click .button-demo': (e) ->
    e.preventDefault()
    # Scroll to top before opening timeline, in order to land the timeline
    # exactly on the user "cover"
    $('html, body').scrollTop(0)
    # The demo is currently hardcoded to Siver's timeline
    App.router.navigate('sivers', trigger: true)
