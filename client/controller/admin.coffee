Template.admin.adminTabs = ->
  module: AdminTabs
  globalReference: 'adminTabs'

# Entries tab
Template.admin.adminEntries = ->
  module: AdminEntries
  model: 'Entry'
  updateModal: 'postModal'
  deleteModal: 'deletePostModal'

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

# Users tab
Template.admin.adminUsers = ->
  module: AdminUsers
  model: 'User'
  deleteModal: 'deleteUserModal'

Template.admin.deleteUserModal = ->
  module: FormModal
  template: Template.deleteModal
  formClass: 'DeleteForm'
  formModel: 'User'
  globalReference: 'deleteUserModal'

# Exports tab
Template.admin.adminExports = ->
  module: AdminExports
  model: 'Export'
  deleteModal: 'deleteExportModal'

Template.admin.deleteExportModal = ->
  module: FormModal
  template: Template.deleteModal
  formClass: 'DeleteForm'
  formModel: 'Export'
  globalReference: 'deleteExportModal'

# Campaigns tab
Template.admin.adminCampaigns = ->
  module: AdminCampaigns
  model: 'Campaign'
  updateModal: 'campaignModal'
  deleteModal: 'deleteCampaignModal'

Template.admin.campaignModal = ->
  module: FormModal
  formModel: 'Campaign'
  formTemplate: Template.campaignForm
  globalReference: 'campaignModal'

Template.admin.deleteCampaignModal = ->
  module: FormModal
  template: Template.deleteModal
  formClass: 'DeleteForm'
  formModel: 'Campaign'
  globalReference: 'deleteCampaignModal'

# Suggestions tab
Template.admin.adminSuggestions = ->
  module: AdminSuggestions
  model: 'SurveySuggestion'
  deleteModal: 'deleteSuggestionModal'

Template.admin.deleteSuggestionModal = ->
  module: FormModal
  template: Template.deleteModal
  formClass: 'DeleteForm'
  formModel: 'SurveySuggestion'
  globalReference: 'deleteSuggestionModal'
