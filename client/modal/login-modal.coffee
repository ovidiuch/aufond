class @LoginModal extends FormModal
  formModel: 'User'
  formClass: 'LoginForm'

  onSuccess: ->
    super()
    # Go to /admin whenever the login form succeeds
    App.router.navigate('admin', trigger: true)
