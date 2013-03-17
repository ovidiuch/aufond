class FormModal extends Modal
  formClass: 'Form'

  events:
    'click .btn-primary': 'onSubmit'
    'keyup input': 'onKeyUp'

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

  update: (data) ->
    # Extract id attribute from data and load model data inside the form
    @reactiveBody.loadModel(data.id)
    # Also update the modal template with the non form-related attributes
    super(data)

  onKeyUp: (e) =>
    # Submit container form when pressing ENTER inside an input (it will not be
    # done automatically because forms loaded inside a modal have their submit
    # button outside their <form> DOM tag)
    if e.keyCode is 13
      @reactiveBody.submit()

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
