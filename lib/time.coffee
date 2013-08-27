@Time =
  now: ->
    ###
      Get univeral time on both client and server, using the server's time
      because it's the only one constant between all users
    ###
    time = new Date().getTime()
    # Account for client-server time differences, but return exactly the same
    # time if not called from client
    if Meteor.isClient and App.serverTimeOffset
      time -= App.serverTimeOffset
    return time
