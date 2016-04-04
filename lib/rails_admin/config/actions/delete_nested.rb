require 'rails_admin/config/actions/edit'

module RailsAdmin
  module Config
    module Actions
      class DeleteNested < Delete
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          false
        end

        register_instance_option :nested_member do
          true
        end


        register_instance_option :breadcrumb_parent do
          [:index_nested, bindings[:controller].try(:nested_abstract_model), bindings[:controller].try(:nested_object)]
        end

        # View partial name (called in default :controller block)
        register_instance_option :template_name do
          :delete_nested
        end

      end
    end
  end
end
