class @ProfileForm extends Form
  template: Template.profileForm

  onSuccess: ->
    @update(success: "Profile updated successfully", true)

  getDataFromForm: ->
    data = super()
    @parseProfileLinks(data)
    return data

  extractModelData: ->
    data = super(arguments...)
    # Add params for filepicker template
    data.profileAvatar =
      module: FilePicker
      field: 'profile.avatar'
      value: data.profile.avatar
    return data

  parseProfileLinks: (data) ->
    ###
      Parse links and turn input values into proper structure. Note: data is
      still flat at this point, it will get nested only after it reaches the
      model
    ###
    addresses = data['profile.links.address']
    icons = data['profile.links.icon']
    links = []

    # Link values come as strings if there's only one row in the form, we need
    # to ensure their array structure
    if _.isString(addresses)
      addresses = [addresses]
      icons = [icons]

    for address, i in addresses
      # Ignore completely blank rows
      continue unless address or icons[i]
      links.push
        address: address
        icon: icons[i]

    # Delete specific keys used by the inputs
    delete data['profile.links.address']
    delete data['profile.links.icon']
    # Add parsed links into original data object, as an array of objects
    data['profile.links'] = links
