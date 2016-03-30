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

      end
    end
  end
end
