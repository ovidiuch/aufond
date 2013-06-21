class @PostImageModal extends FormModal
  formModel: 'Entry'
  formClass: 'PostImageForm'

  update: (data) ->
    # Attach specific Entry image to corresponding form
    @reactiveBody.postImage = data.image
    super(data)
