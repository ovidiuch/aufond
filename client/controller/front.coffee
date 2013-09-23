Template.front.events
  'click .button-demo': (e) ->
    e.preventDefault()
    # The demo is currently hardcoded to Siver's timeline
    App.router.navigate('sivers', {trigger: true, resetScroll: true})

  'click .link-thanks': (e) ->
    e.preventDefault()
    App.router.navigate('thanks', {trigger: true, resetScroll: true})
