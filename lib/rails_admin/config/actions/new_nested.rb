require 'rails_admin/config/actions/new'

module RailsAdmin
  module Config
    module Actions
      class NewNested < New
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :collection do
          false
        end

        register_instance_option :has_many_nested_collection do
          true
        end

        register_instance_option :breadcrumb_parent do
          [:index_nested, bindings[:controller].try(:parent_abstract_model), bindings[:controller].try(:parent_object)]
        end

        # View partial name (called in default :controller block)
        register_instance_option :template_name do
          :new
        end

        # For Cancan and the like
        register_instance_option :authorization_key do
          :new
        end

      end
    end
  end
end
