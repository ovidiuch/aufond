Template.adminUsers.events
  'click .button-user-timeline': (e) ->
    e.preventDefault()
    username = $(e.currentTarget).data('username')
    App.router.navigate("#{username}", trigger: true)

  'click .button-delete': (e) ->
    e.preventDefault()
    App.deleteUserModal.update($(e.currentTarget).data())

Template.adminUsers.users = ->
  # Show users with more entries first
  return _.sortBy(User.get().toJSON(), (user) -> -user.entryCount)
