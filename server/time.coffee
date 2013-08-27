Meteor.methods
  serverTime: (callback) ->
    now = Date.now()
    callback(now) if _.isFunction(callback)
    # Support sync response as well, just in case
    return now
