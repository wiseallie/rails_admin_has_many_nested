require 'rails_admin/config/actions/history_index'

module RailsAdmin
  module Config
    module Actions
      class HistoryIndexNested < HistoryIndex
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :collection do
          false
        end

        register_instance_option :member do
          false
        end

        register_instance_option :nested_collection do
          true
        end

        register_instance_option :route_fragment do
          'history_nested'
        end

        register_instance_option :authorization_key do
          :history_nested
        end


        # View partial name (called in default :controller block)
        register_instance_option :template_name do
          :history_nested
        end

      end
    end
  end
end
