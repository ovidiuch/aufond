class PostModal extends FormModal
  formModel: 'Entry'
  formTemplate: Template.post_form

  constructor: ->
    super(arguments...)
    # Create global reference to post modal
    App.postModal = this
