# Store a time offset between the client and the server, in order to have
# correct "time ago" estimations relative to createdAt-like timestamps (which
# are set on the server)
Meteor.call 'serverTime', (err, serverTime) ->
  clientTime = new Date().getTime()
  # This offset is in milliseconds
  App.serverTimeOffset = if serverTime then clientTime - serverTime else 0
