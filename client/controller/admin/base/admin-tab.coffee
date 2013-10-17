class @AdminTab extends ReactiveTemplate
  ###
    Abstract class for an admin tab listing editable items of a collection
  ###
  events:
    'click .button-create': 'onCreate'
    'click .button-view': 'onView'
    'click .button-edit': 'onEdit'
    'click .button-delete': 'onDelete'

  constructor: ->
    super(arguments...)
    if @params.updateModal
      @updateModal = App[@params.updateModal]
    if @params.deleteModal
      @deleteModal = App[@params.deleteModal]

  decorateTemplateData: (data) ->
    ###
      Hook reactive context to the collection data of by requesting it inside
      the render callback, after the reactive context has been enabled
    ###
    data = super(data)
    data.items = @getCollectionItems()
    return data

  onCreate: (e) =>
    e.preventDefault()
    @updateModal.update($(e.currentTarget).data())

  onView: (e) =>
    # Implement in subclass

  onEdit: (e) =>
    e.preventDefault()
    @updateModal.update($(e.currentTarget).data())

  onDelete: (e) =>
    e.preventDefault()
    @deleteModal.update($(e.currentTarget).data())

  getCollectionItems: ->
    # Default to items of the current user in descending order
    return @getModelClass().get(
      {createdBy: Meteor.userId()},
      {sort: {createdAt: -1}}
    ).toJSON()

  getModelClass: ->
    return window[@params.model]
