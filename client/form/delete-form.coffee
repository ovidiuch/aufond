class @DeleteForm extends Form
  template: Template.deleteForm

  submit: ->
    @clearStatus()
    userId = Meteor.userId()

    # Delete account permanently
    # XXX A warning step might be needed
    User.remove(userId, true)
