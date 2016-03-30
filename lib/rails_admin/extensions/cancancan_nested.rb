require 'rails_admin/extensions/cancancan_nested/authorization_adapter'

RailsAdmin.add_extension(:cancan_nested, RailsAdmin::Extensions::CanCanCanNested, authorization: true)
