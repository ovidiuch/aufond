class @DeletePostImageForm extends DeleteForm
  ###
    Custom form for deleting post images. The major difference from a normal
    delete form is that we're only removing a property off the model, and not
    its entire document
  ###
  submit: ->
    unless @params.model?
      throw new Error "Delete form has no model attached"
    unless @model?
      throw new Error "Delete form has no id for #{@params.model} model"
    unless @postImage?
      throw new Error "Post image delete form has no image attached"

    @model.removeImage @postImage, (error) =>
      if error
        @onError(error)
      else if _.isFunction(@onSuccess)
        @onSuccess()
