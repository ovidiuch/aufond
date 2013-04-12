class @PostModal extends FormModal
  formModel: 'Entry'
  formTemplate: Template.postForm

  constructor: ->
    super(arguments...)
    # Create global reference to post modal
    App.postModal = this
