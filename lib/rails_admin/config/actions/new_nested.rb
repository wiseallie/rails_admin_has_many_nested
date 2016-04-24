require 'rails_admin/config/actions/new'

module RailsAdmin
  module Config
    module Actions
      class NewNested < New
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :collection do
          false
        end

        register_instance_option :nested_collection do
          true
        end

        register_instance_option :breadcrumb_parent do
          [:index_nested, bindings[:controller].try(:parent_abstract_model), bindings[:controller].try(:parent_object)]
        end

        # View partial name (called in default :controller block)
        register_instance_option :template_name do
          :new_nested
        end

        register_instance_option :controller do
          proc do
            if request.get? # NEW

              @object = @abstract_model.new
              @authorization_adapter && @authorization_adapter.attributes_for(:new_nested, @abstract_model).each do |name, value|
                @object.send("#{name}=", value)
              end
              if object_params = params[@abstract_model.to_param]
                @object.set_attributes(@object.attributes.merge(object_params))
              end
              respond_to do |format|
                format.html { render @action.template_name }
                format.js   { render @action.template_name, layout: false }
              end

            elsif request.post? # CREATE

              @modified_assoc = []
              @object = @abstract_model.new
              sanitize_params_for!(request.xhr? ? :modal : :create)

              @object.set_attributes(params[@abstract_model.param_key])
              @authorization_adapter && @authorization_adapter.attributes_for(:create, @abstract_model).each do |name, value|
                @object.send("#{name}=", value)
              end
              if @object.save
                @auditing_adapter && @auditing_adapter.create_object(@object, @abstract_model, _current_user)
                respond_to do |format|
                  format.html { redirect_to_on_success_nested(@pjax_nested ? {pjax_nested: true} : {}) }
                  format.js   { render json: {id: @object.id.to_s, label: @model_config.with(object: @object).object_label} }
                end
              else
                handle_save_error :new_nested
              end

            end
          end
        end
      end
    end
  end
end
