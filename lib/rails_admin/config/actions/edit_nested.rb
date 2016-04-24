require 'rails_admin/config/actions/edit'

module RailsAdmin
  module Config
    module Actions
      class EditNested < Edit
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
          :edit_nested
        end

        register_instance_option :controller do
          proc do
            if request.get? # EDIT

              respond_to do |format|
                format.html { render @action.template_name }
                format.js   { render @action.template_name, layout: false }
              end

            elsif request.put? # UPDATE
              sanitize_params_for!(request.xhr? ? :modal : :update)

              @object.set_attributes(params[@abstract_model.param_key])
              @authorization_adapter && @authorization_adapter.attributes_for(:update_nested, @abstract_model).each do |name, value|
                @object.send("#{name}=", value)
              end
              changes = @object.changes
              if @object.save
                @auditing_adapter && @auditing_adapter.update_object(@object, @abstract_model, _current_user, changes)
                respond_to do |format|
                  format.html { redirect_to_on_success_nested(@pjax_nested ? {pjax_nested: true} : {}) }
                  format.js { render json: {id: @object.id.to_s, label: @model_config.with(object: @object).object_label} }
                end
              else
                handle_save_error :edit_nested
              end
            end
          end
        end


      end
    end
  end
end
