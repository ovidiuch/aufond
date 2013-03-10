Template.front.events
  'click .btn-register': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.registerModal.update(data)

  'click .btn-login': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.loginModal.update(data)
