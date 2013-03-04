class LoginModal extends FormModal
  formModel: 'User'
  formClass: 'LoginForm'

  constructor: ->
    super(arguments...)

    # XXX create global reference in order for it to be used from anywhere
    Aufond.loginModal = this
