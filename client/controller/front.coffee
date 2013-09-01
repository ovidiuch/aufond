Template.front.events
  'click .button-demo': (e) ->
    e.preventDefault()
    # The demo is currently hardcoded to Siver's timeline
    App.router.navigate('sivers', {trigger: true, resetScroll: true})
