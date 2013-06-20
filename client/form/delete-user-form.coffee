class @DeleteUserForm extends DeleteForm
  template: Template.deleteUserForm

  submit: ->
    # Track user deletes in Mixpanel
    mixpanel.track('user delete')
    # Delete user permanently
    super()
