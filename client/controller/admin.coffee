Template.admin.events
  'click .button-post': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.postModal.update(data)

Template.admin.postModal = ->
  module: PostModal

Template.admin.postImageModal = ->
  module: PostImageModal
