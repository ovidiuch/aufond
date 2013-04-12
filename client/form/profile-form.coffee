class @ProfileForm extends Form
  template: Template.profileForm

  decorateTemplateData: ->
    data = super(arguments...)

    # Add params for filepicker template
    data.profileAvatar =
      module: FilePicker
      field: 'profile.avatar'
      value: data.profile?.avatar

    return data

  onSuccess: ->
    @update(success: "Profile updated successfully", true)
