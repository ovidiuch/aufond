Template.adminDeleteAccount.events
  'click .button-delete': (e) ->
    e.preventDefault()
    data = _.extend {id: Meteor.userId()}, $(e.currentTarget).data()
    App.deleteUserModal.update(data)

Template.adminMeta.profileForm = ->
  module: ProfileForm
  model: 'User'
  modelId: Meteor.userId()

Template.adminMeta.emailForm = ->
  module: EmailForm
  model: 'User'
  modelId: Meteor.userId()

Template.adminMeta.passwordForm = ->
  module: PasswordForm
