Template.front.events
  'click .btn-register': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    Aufond.registerModal.update(data)

  'click .btn-login': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    Aufond.loginModal.update(data)
