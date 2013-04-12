class @PostImageModal extends FormModal
  formModel: 'Entry'
  formClass: 'PostImageForm'

  constructor: ->
    super(arguments...)
    # Create global reference to post modal
    App.postImageModal = this

  update: (data) ->
    super(data)
    # Load specific Entry image in corresponding form
    @reactiveBody.loadImage(data.image)
