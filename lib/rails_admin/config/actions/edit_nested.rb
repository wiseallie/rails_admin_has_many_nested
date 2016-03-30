require 'rails_admin/config/actions/edit'

module RailsAdmin
  module Config
    module Actions
      class EditNested < Edit
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          false
        end

        register_instance_option :has_many_nested_member do
          true
        end

        # View partial name (called in default :controller block)
        register_instance_option :template_name do
          :edit
        end

        # For Cancan and the like
        register_instance_option :authorization_key do
          :edit
        end

      end
    end
  end
end
