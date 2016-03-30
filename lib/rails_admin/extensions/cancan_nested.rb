require 'rails_admin/extensions/cancan_nested/authorization_adapter'

RailsAdmin.add_extension(:cancan_nested, RailsAdmin::Extensions::CanCanNested, authorization: true)
