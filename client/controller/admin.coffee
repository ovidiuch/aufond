Template.admin.adminTabs = ->
  module: AdminTabs
  globalReference: 'adminTabs'

Template.admin.postModal = ->
  module: FormModal
  formModel: 'Entry'
  formTemplate: Template.postForm
  globalReference: 'postModal'

Template.admin.deletePostModal = ->
  module: FormModal
  template: Template.deleteModal
  formClass: 'DeleteForm'
  formModel: 'Entry'
  globalReference: 'deletePostModal'

Template.admin.postImageModal = ->
  module: PostImageModal
  globalReference: 'postImageModal'

Template.admin.deletePostImageModal = ->
  module: PostImageModal
  template: Template.deleteModal
  formClass: 'DeletePostImageForm'
  globalReference: 'deletePostImageModal'

Template.admin.deleteUserModal = ->
  module: FormModal
  template: Template.deleteModal
  formClass: 'DeleteForm'
  formModel: 'User'
  globalReference: 'deleteUserModal'
