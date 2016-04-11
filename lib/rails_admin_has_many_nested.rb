require "rails_admin"
require 'rails_admin/nested_abstract_model'
require 'rails_admin/extensions/pundit_nested'
require 'rails_admin/extensions/cancan_nested'
require 'rails_admin/extensions/cancancan_nested'
require 'rails_admin/config/fields/types/has_many_nested_association_extension'
require 'rails_admin/config/actions_extension'
require 'rails_admin/config/model_extension'
require 'rails_admin/controllers/concerns/application_concern'

require "rails_admin_has_many_nested/engine"
require "rails_admin_has_many_nested/version"

module RailsAdminHasManyNested

end
