class @DeleteForm extends Form
  template: Template.deleteForm
  submitButton: '.button-danger'

  submit: ->
    # Track user deletes in Mixpanel
    mixpanel.track('user delete')

    # Delete account permanently
    # XXX A warning step might be needed
    User.remove(Meteor.userId(), true)
