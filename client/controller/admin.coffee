Template.admin.events
  'mouseup .button-timeline': (e) ->
    e.preventDefault()
    username = Meteor.user().username
    App.router.navigate("#{username}", trigger: true)

  'mouseup .button-logout': (e) ->
    e.preventDefault()
    User.logout()

  'mouseup .button-post': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.postModal.update(data)

Template.admin.postModal = ->
  module: PostModal

Template.admin.postImageModal = ->
  module: PostImageModal
