Handlebars.registerHelper 'match', (options) ->
  # Match a key-value hash against the current scope and act as an if/else
  # block, depending on their equality
  for k, v of options.hash
    if v isnt this[k]
      # Return false if any of the compared keys have a different value in the
      # current scope
      return options.inverse(this)
  return options.fn(this)
