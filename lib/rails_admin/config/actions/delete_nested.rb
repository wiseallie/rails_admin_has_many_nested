require 'rails_admin/config/actions/edit'

module RailsAdmin
  module Config
    module Actions
      class DeleteNested < Delete
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
          :delete_nested
        end

        register_instance_option :controller do
          proc do
            if request.get? # DELETE

              respond_to do |format|
                format.html { render @action.template_name }
                format.js   { render @action.template_name, layout: false }
              end

            elsif request.delete? # DESTROY

              redirect_path = nil
              @auditing_adapter && @auditing_adapter.delete_object(@object, @abstract_model, _current_user)
              if @object.destroy
                flash[:success] = t('admin.flash.successful', name: @model_config.label, action: t('admin.actions.delete_nested.done'))
                redirect_path = index_nested_path(@pjax_nested ? {pjax_nested: true} : {})
              else
                flash[:error] = t('admin.flash.error', name: @model_config.label, action: t('admin.actions.delete_nested.done'))
                redirect_path =  back_or_index_nested(@pjax_nested ? {pjax_nested: true} : {})
              end

              redirect_to redirect_path

            end
          end
        end

      end
    end
  end
end
