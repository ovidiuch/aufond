class @FormModal extends Modal
  formClass: 'Form'

  events:
    'click .button-primary': 'onSubmit'

  constructor: ->
    super(arguments...)
    @createForm()

  createForm: ->
    ###
      Create reactive container for associated form.
      Important: A Form class and a MeteorModel class is required
    ###
    params =
      model: @params.formModel or @formModel
      onSuccess: @onSuccess

    # More than one template might be used for the same Form class, so a
    # custom template can be specified
    formTemplate = @params.formTemplate or @formTemplate
    if formTemplate?
      params.template = formTemplate

    # The reactive body in this modal is a Form instance and thus has all of
    # its interface methods available (such as loading a model via "load")
    @reactiveBody = new window[@params.formClass or @formClass](params)
    # HACK disable the submit event on child forms (since it will be triggered
    # from the model class on key up instead)
    @reactiveBody.onSubmit = (e) -> e.preventDefault()

  update: (data) ->
    # Extract id attribute from data and load model data inside the form
    @reactiveBody.loadModel(data.id)
    # Also update the modal template with the non form-related attributes
    super(data)

  onSubmit: =>
    ###
      Submit the form on modal submit, which then closes the modal on success
    ###
    @reactiveBody.submit()

  onSuccess: =>
    ###
      Called when the contained form succeeds. Extend in subclasses
    ###
    @close()
