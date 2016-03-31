require 'rails_admin/config/actions/edit'

module RailsAdmin
  module Config
    module Actions
      class DeleteNested < Delete
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          false
        end

        register_instance_option :has_many_nested_member do
          true
        end

        register_instance_option :breadcrumb_parent do
          [:index_nested, bindings[:controller].try(:nested_abstract_model), bindings[:controller].try(:nested_object)]
        end

      end
    end
  end
end
