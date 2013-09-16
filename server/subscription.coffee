Meteor.methods
  unsubscribe: (id) ->
    ###
      Method for unsubscribing an user from notification, by simply setting
      the isSubscribed property to false (which is inaccessible from the
      client-slide)
    ###
    user = User.find(id)
    user.save(isSubscribed: false) if user?
