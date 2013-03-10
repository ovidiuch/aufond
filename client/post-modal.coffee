class PostModal extends FormModal
  formModel: 'Entry'
  formTemplate: 'post_form'

  constructor: ->
    super(arguments...)
    # Create global reference to post modal
    App.postModal = this
