Template.admin.events
  'click .button-timeline': (e) ->
    e.preventDefault()
    username = Meteor.user().username
    App.router.navigate("#{username}", trigger: true)

  'click .button-logout': (e) ->
    e.preventDefault()

    # Track signouts in Mixpanel
    username = Meteor.user()?.username
    mixpanel.track('logout', username: username)

    User.logout()

  'click .button-post': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.postModal.update(data)

Template.admin.postModal = ->
  module: PostModal

Template.admin.postImageModal = ->
  module: PostImageModal
