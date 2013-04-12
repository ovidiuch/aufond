class @RegisterModal extends FormModal
  formModel: 'User'
  formClass: 'RegisterForm'

  constructor: ->
    super(arguments...)
    # Create global reference to register modal
    App.registerModal = this

  onSuccess: ->
    super()
    # Go to /admin whenever the login form succeeds
    App.router.navigate('admin', trigger: true)
