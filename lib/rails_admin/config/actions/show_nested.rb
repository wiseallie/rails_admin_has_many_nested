require 'rails_admin/config/actions/show'

module RailsAdmin
  module Config
    module Actions
      class ShowNested < Show
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          false
        end

        register_instance_option :has_many_nested_member do
          true
        end

        register_instance_option :breadcrumb_parent do
          [:show, bindings[:parent_abstract_model], bindings[:parent_object], bindings[:association_name], bindings[:nested_object]]
        end

        # View partial name (called in default :controller block)
        register_instance_option :template_name do
          :show
        end

        # For Cancan and the like
        register_instance_option :authorization_key do
          :show
        end

      end
    end
  end
end
