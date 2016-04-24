require 'rails_admin/config/actions/export'
module RailsAdmin
  module Config
    module Actions
      class ExportNested  < Export
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :collection do
          false
        end

        register_instance_option :nested_collection do
          true
        end

        # View partial name (called in default :controller block)
        register_instance_option :template_name do
          :export_nested
        end

        register_instance_option :controller do
          proc do
            if format = params[:json] && :json || params[:csv] && :csv || params[:xml] && :xml
              request.format = format
              @schema = HashHelper.symbolize(params[:schema]) if params[:schema] # to_json and to_xml expect symbols for keys AND values.
              @objects = list_entries(@model_config, :export)
              index_nested
            else
              render @action.template_name
            end
          end
        end
      end
    end
  end
end
