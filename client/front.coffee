Template.front.events
  'click .btn-login': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    Aufond.loginModal.update(data)
