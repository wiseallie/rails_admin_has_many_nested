require 'rails_admin/config/actions/export'
module RailsAdmin
  module Config
    module Actions
      class ExportNested  < Export
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :collection do
          false
        end

        register_instance_option :has_many_nested_collection do
          true
        end

      end
    end
  end
end
