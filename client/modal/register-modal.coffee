class @RegisterModal extends FormModal
  formModel: 'User'
  formClass: 'RegisterForm'

  onSuccess: ->
    super()
    # Go to /admin whenever the login form succeeds
    App.router.navigate('admin', trigger: true)
