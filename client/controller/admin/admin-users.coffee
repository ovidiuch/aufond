Template.adminUsers.events
  'click .btn-user-timeline': (e) ->
    e.preventDefault()
    username = $(e.currentTarget).data('username')
    App.router.navigate("#{username}", trigger: true)

  'click .btn-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    User.remove(data.id)

Template.adminUsers.users = ->
  return User.get().toJSON()
