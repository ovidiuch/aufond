class @PostImageForm extends Form
  template: Template.postImageForm

  extractModelData: ->
    # Use an Entry image as the data source for this form, the @postImage value
    # should be set before attaching the Entry model to this form
    @model.getImage(@postImage)

  updateModel: (data) ->
    # Update image object (it is referenced from the Entry data directly)
    image = @model.getImage(@postImage)
    image.caption = data.caption
    # Trigger "images" as a changed field
    @model.set(images: @model.get('images'))
