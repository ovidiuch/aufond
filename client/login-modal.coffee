class LoginModal extends FormModal
  formModel: 'User'
  formClass: 'LoginForm'

  constructor: ->
    super(arguments...)

    # XXX create global reference in order for it to be used from anywhere
    Aufond.loginModal = this

  onSuccess: ->
    super()
    # Go to /admin whenever the login form succeeds
    Aufond.router.navigate('admin', trigger: true)
