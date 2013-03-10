class LoginModal extends FormModal
  formModel: 'User'
  formClass: 'LoginForm'

  constructor: ->
    super(arguments...)
    # Create global reference to login modal
    App.loginModal = this

  onSuccess: ->
    super()
    # Go to /admin whenever the login form succeeds
    App.router.navigate('admin', trigger: true)
