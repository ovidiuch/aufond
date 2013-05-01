Template.front.events
  'mouseup .button-register': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.registerModal.update(data)

  'mouseup .button-login': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.loginModal.update(data)
