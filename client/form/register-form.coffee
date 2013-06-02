class @RegisterForm extends Form
  template: Template.registerForm

  submit: ->
    data = @getDataFromForm()
    @updateFormData(data)

    options =
      username: data.username
      email: data.email
      password: data.password
      profile:
        name: data.name

    # Validate user data beforehand
    error = null
    if not options.username
      error = 'Please choose a neat username for your account'
    else if not options.username.match /^[a-z0-9._-]+$/i
      error = 'What is _that_? Please use **a-z0-9._-** chars for your username'
    else if options.username.length < 2
      error = 'One more char, bro'
    else if User.find(username: options.username)
      error = 'Username is already taken :('
    else if not options.password
      error = 'Come on, you need a password for _any_ account'

    # Track signups in Mixpanel
    mixpanel.track 'register',
      username: data.username
      email: data.email
      name: data.name
      error: error

    if error
      @onError(error)
    else
      Accounts.createUser options, (error) =>
        if error
          # XXX send custom error to users
          @onError(error.reason)
        else if _.isFunction(@onSuccess)
          @onSuccess()
