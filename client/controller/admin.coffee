Template.admin.events
  'click .btn-timeline': (e) ->
    username = Meteor.user().username
    App.router.navigate("#{username}", trigger: true)

  'click .btn-logout': (e) ->
    User.logout()

  'click .btn-post': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.postModal.update(data)

Template.admin.postModal = ->
  module: PostModal

Template.admin.postImageModal = ->
  module: PostImageModal
