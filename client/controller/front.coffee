Template.front.events
  'click .button-demo': (e) ->
    e.preventDefault()
    # Scroll to top before opening timeline, in order to land the timeline
    # exactly on the user "cover"
    $('html, body').scrollTop(0)
    # The demo is currently hardcoded to Siver's timeline
    App.router.navigate('sivers', trigger: true)
