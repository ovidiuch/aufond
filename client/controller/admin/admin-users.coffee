Template.adminUsers.events
  'click .button-user-timeline': (e) ->
    e.preventDefault()
    username = $(e.currentTarget).data('username')
    App.router.navigate("#{username}", trigger: true)

  'click .button-delete': (e) ->
    e.preventDefault()
    App.deleteUserModal.update($(e.currentTarget).data())

Template.adminUsers.users = ->
  # Show users in the descending order of their creation
  return User.get({}, {sort: {createdAt: 1}}).toJSON()
