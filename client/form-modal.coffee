class FormModal extends Modal

  constructor: ->
    super(arguments...)

    # The reactive body in this modal is a Form instance and thus has all of
    # its interface methods available (such as loading a model via "load")
    @reactiveBody = new Form
      templateName: @formTemplate
      model: @formModel

    # Submit the form on modal submit, which then closes the modal on success
    @onSubmit = =>
        @reactiveBody.submit => @close()

  update: (data) ->
    # Extract id attribute from data and load model data inside the form
    @reactiveBody.load(data.id)
    # Also update the modal template with the non form-related attributes
    super(data)
