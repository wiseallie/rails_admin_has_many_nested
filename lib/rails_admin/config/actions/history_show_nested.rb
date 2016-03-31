require 'rails_admin/config/actions/history_show'

module RailsAdmin
  module Config
    module Actions
      class HistoryShowNested  < HistoryShow
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          false
        end

        register_instance_option :has_many_nested_member do
          true
        end
        
        # View partial name (called in default :controller block)
        register_instance_option :template_name do
          :history_show_nested
        end
      end
    end
  end
end
