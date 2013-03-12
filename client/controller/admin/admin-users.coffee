Template.adminUsers.events
  'click .btn-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    User.remove(data.id)

Template.adminUsers.users = ->
  return User.get().toJSON()
