Template.front.entries = ->
  # Extract with years
  return Entry.get({}, sort: {time: -1}).toJSON()
