@trackAction = (action, params = {}) ->
  # XXX disable tracking timeline entries for now because they represent over
  # 80% of all user actions and hence cost most of the available Mixpanel data
  # points (https://mixpanel.com/pricing/)
  return if action is 'timeline entry'
  if _.isFunction(mixpanel?.track)
    mixpanel.track(action, params)

@trackUser = (user) ->
  if _.isFunction(mixpanel?.register)
    mixpanel.register
      user_handle: user.get('username')
      user_email: user.getEmail()
      user_name: user.get('name')
