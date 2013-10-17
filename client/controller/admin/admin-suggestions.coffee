class @AdminSuggestions extends AdminTab
  template: Template.adminSuggestions

  getCollectionItems: ->
    # Suggestions shouldn't be filtered by user, they are created by guests
    return SurveySuggestion.get().toJSON()
