class @PostImageForm extends Form
  template: Template.postImageForm

  loadModel: (id) ->
    ###
      Extend the way the model is loaded and just save its reference w/out
      rendering anything (a specific image will be loaded afterwards)
    ###
    # This form only work on existing entries (an image can't be attached to
    # no entry)
    @model = @getModelClass().find(id)

  loadImage: (imageUrl) ->
    ###
      Render form template with the attributes of an Entry image
    ###
    # Also store reference to image so it can be modified later (on submit)
    @update(@image = @model.getImage(imageUrl))

  submit: ->
    ###
      Only update image caption
    ###
    @clearStatus()
    # Update image object (it is referenced from the Entry data directly)
    @image.caption = @getDataFromForm().caption
    # Trigger "images" as a changed field
    @model.save images: @model.get('images'), (error, model) =>
      if error
        @onError(error)
      else
        # The form will surely be loaded w/ an onSuccess handler from the modal
        @onSuccess()
