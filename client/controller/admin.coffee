Template.admin.events
  'click .button-post': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.postModal.update(data)

Template.admin.postModal = ->
  module: FormModal
  formModel: 'Entry'
  formTemplate: Template.postForm
  globalReference: 'postModal'

Template.admin.postImageModal = ->
  module: PostImageModal
  globalReference: 'postImageModal'
