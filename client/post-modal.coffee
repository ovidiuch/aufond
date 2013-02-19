class PostModal extends Modal

  constructor: ->
    super(arguments...)

    @reactiveBody = new Form
      templateName: 'post_form'
      collection: Entry

    # Submit the form on modal submit, which closes the modal on success
    @onSubmit = =>
        @reactiveBody.submit => @close()

    # XXX create global reference in order for it to be used from anywhere
    Aufond.postModal = this

  loadPost: (id) ->
    ###
      Load post entry inside the contained form
    ###
    @reactiveBody.load(id)
