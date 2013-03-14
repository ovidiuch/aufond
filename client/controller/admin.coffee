Template.admin.events
  'click .btn-timeline': (e) ->
    username = Meteor.user().username
    App.router.navigate("#{username}", trigger: true)

  'click .btn-logout': (e) ->
    Meteor.logout (error) ->
      if error
        # XXX handle logout error
      else
        App.router.navigate('', trigger: true)

  'click .btn-post': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.postModal.update(data)

Template.admin.postModal = ->
  module: PostModal
