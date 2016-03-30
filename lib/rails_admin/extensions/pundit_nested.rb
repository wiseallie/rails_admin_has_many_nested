require 'rails_admin/extensions/pundit_nested/authorization_adapter'

RailsAdmin.add_extension(:pundit_nested, RailsAdmin::Extensions::PunditNested, authorization: true)
