class @DeleteForm extends Form
  template: Template.deleteForm

  submit: ->
    # Delete account permanently
    # XXX A warning step might be needed
    User.remove(Meteor.userId(), true)
