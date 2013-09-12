Template.adminSuggestions.events
  'click .button-delete': (e) ->
    e.preventDefault()
    App.deleteSuggestionModal.update($(e.currentTarget).data())

Template.adminSuggestions.suggestions = ->
  return SurveySuggestion.get({}, sort: {time: -1}).toJSON()
