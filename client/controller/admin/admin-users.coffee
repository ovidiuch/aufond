class @AdminUsers extends AdminTab
  template: Template.adminUsers

  onView: (e) =>
    e.preventDefault()
    username = $(e.currentTarget).data('username')
    App.router.navigate("#{username}", trigger: true)

  getCollectionItems: ->
    # Admins should see all users
    return User.get().toJSON()
