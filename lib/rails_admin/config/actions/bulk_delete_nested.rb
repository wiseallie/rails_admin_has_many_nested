require 'rails_admin/config/actions/bulk_delete'

module RailsAdmin
  module Config
    module Actions
      class BulkDeleteNested < BulkDelete
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
