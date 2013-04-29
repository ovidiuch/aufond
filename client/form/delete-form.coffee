class @DeleteForm extends Form
  template: Template.deleteForm
  submitButton: '.button-danger'

  submit: ->
    # Delete account permanently
    # XXX A warning step might be needed
    User.remove(Meteor.userId(), true)
