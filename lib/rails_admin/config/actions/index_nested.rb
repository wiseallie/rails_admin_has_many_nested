require 'rails_admin/config/actions/index'
module RailsAdmin
  module Config
    module Actions
      class IndexNested < Index
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :association_nested_action do
          true
        end

        register_instance_option :collection do
          false
        end

        register_instance_option :nested_collection do
          true
        end

        register_instance_option :breadcrumb_parent do
          [:show, bindings[:controller].try(:parent_abstract_model), bindings[:controller].try(:parent_object)]
        end

        # View partial name (called in default :controller block)
        register_instance_option :template_name do
          :index_nested
        end

      end
    end
  end
end
