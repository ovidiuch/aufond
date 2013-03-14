class ProfileForm extends Form
  template: Template.profileForm

  onSuccess: ->
    @update(success: "Profile updated successfully", true)
