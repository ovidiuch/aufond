Template.front.events
  'click .button-register': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.registerModal.update(data)

  'click .button-login': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.loginModal.update(data)
