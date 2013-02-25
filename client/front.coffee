Template.front.entries = ->
  return Entry.getByYears()

Template.front.iconClass = (icon) ->
  return icon or 'icon-circle'
