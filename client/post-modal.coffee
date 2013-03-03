class PostModal extends FormModal
  formModel: 'Entry'
  formTemplate: 'post_form'

  constructor: ->
    super(arguments...)

    # XXX create global reference in order for it to be used from anywhere
    Aufond.postModal = this
