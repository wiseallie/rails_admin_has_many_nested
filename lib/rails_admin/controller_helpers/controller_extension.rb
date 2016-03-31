module RailsAdmin
  module ControllerHelpers
    module ControllerExtension
      class ParentModelNotFound < ::StandardError ;end
      class ParentObjectNotFound < ::StandardError; end
      class HasManyConfigNotFound < ::StandardError; end

      extend ActiveSupport::Concern

      def self.included(base)
        base.send(:initialize_has_many_nested)
        base.layout(:get_new_layout)
      end

      module ClassMethods
        ATTR_ACCESSORS_TO_DEFINE = %w(
        parent_object parent_model parent_model_name parent_abstract_model parent_model_config  parent_properties
        object model model_name  abstract_model model_config  properties
        nested_object nested_model nested_model_name nested_abstract_model nested_model_config  nested_properties
        has_many_association_config association_name
        )

        def initialize_has_many_nested
          prepend_before_action :get_nested_object, only: RailsAdmin::Config::Actions.all.select(&:has_many_nested_member).collect(&:action_name)
          prepend_before_action :get_parent_model_and_object_and_nested_model, only: RailsAdmin::Config::Actions.all.select(&:has_many_nested_collection).collect(&:action_name)
          # Does not behave well when there are other before filters
          # because it uses except
          # before_filter :get_model, except: RailsAdmin::Config::Actions.all(:root).collect(&:action_name)
          skip_before_filter :get_model
          prepend_before_action :_get_model, only: [RailsAdmin::Config::Actions.all(:collection).collect(&:action_name), RailsAdmin::Config::Actions.all(:member).collect(&:action_name)].flatten

          rescue_from ParentModelNotFound do
            flash[:error] = I18n.t('admin.flash.parent_model_not_found', parent_model: @parent_model_name)
            params[:action] = 'dashboard'
            dashboard
          end

          rescue_from ParentObjectNotFound do
            flash[:error] = I18n.t('admin.flash.parent_object_not_found', parent_model: @parent_model_name, parent_object_id: params[:parent_object_id])
            params[:action] = 'dashboard'
            dashboard
          end

          rescue_from HasManyConfigNotFound do
            flash[:error] = I18n.t('admin.flash.has_many_association_config', parent_model: @parent_model_name, parent_object_id: params[:parent_object_id], association_name: params[:association_name])
            params[:action] = 'dashboard'
            dashboard
          end

          ClassMethods::ATTR_ACCESSORS_TO_DEFINE.each do |a|
            define_method a.to_sym do
              instance_variable_get("@#{a}")
            end

            define_method "#{a}=(v)".to_sym do |v|
              instance_variable_set("@#{a}", v)
            end
            helper_method a.to_sym
            hide_action a.to_sym
          end
          helper_method :nested_bindings
        end
      end

      # Try and add more bindings to the current action
      # a controller action is called with
      # instance_eval &@action.controller

      def instance_eval(&block)
        if @action && !@action.bindings[:nested_controller_bindings_set]
          @action = @action.with(nested_bindings({controller: self, abstract_model: @abstract_model, object: @object, nested_controller_bindings_set: true}))
        end
        super(&block)
      end

      def nested_bindings(options = {})
        bindings_hash = {
          controller: self, view: view_context, action: @action
        }.with_indifferent_access
        RailsAdmin::ControllerHelpers::ControllerExtension::ClassMethods::ATTR_ACCESSORS_TO_DEFINE.each{|k| bindings_hash[k.to_sym] = send(k)}
        bindings_hash.merge!(options || {})
        bindings_hash
      end


      protected

      # only for the purpose of allowing other before filters to go through
      def _get_model
        get_model
      end

      def bulk_action_nested
        bulk_action
      end

      def to_model_param(m)
        m.to_s.split('::').collect(&:underscore).join('~')
      end

      def get_parent_model_and_object_and_nested_model
        get_parent_model
        get_parent_object
        get_nested_model
      end

      def get_parent_model
        @parent_model_name = to_model_name(params[:parent_model_name])
        @association_name = params[:association_name]
        fail(ParentModelNotFound) unless (@parent_abstract_model = RailsAdmin::AbstractModel.new(@parent_model_name))
        fail(ParentModelNotFound) if (@parent_model_config = @parent_abstract_model.config).excluded?
        fail(HasManyConfigNotFound) unless  (@has_many_association_config = @parent_model_config.nested_has_many_relationships[@association_name]).present?
        @parent_properties = @parent_abstract_model.properties
      end

      def get_parent_object
        fail(ParentObjectNotFound) unless (@parent_object = @parent_abstract_model.get(params[:parent_object_id]))
      end

      def get_nested_model
        @model_name = @nested_model_name = @has_many_association_config.association.options[:class_name]
        fail(RailsAdmin::ModelNotFound) unless (@abstract_model = @nested_abstract_model =  RailsAdmin::NestedAbstractModel.new(@nested_model_name, @parent_object, @association_name))
        fail(RailsAdmin::ModelNotFound) if (@model_config = @nested_model_config = @nested_abstract_model.config).excluded?
        @properties = @nested_properties =  @nested_abstract_model.properties
        params[:model_name] = params['model_name'] = to_model_param(@model_name )
      end

      def get_nested_object
        get_parent_model_and_object_and_nested_model
        fail(RailsAdmin::ObjectNotFound) unless (@object = @nested_object = @nested_abstract_model.get(params[:id]))
      end

      private

      def get_new_layout
        "rails_admin/#{request.headers['X-PJAX'] || params['pjax'] ? 'pjax' : 'application'}"
      end
    end #end  ControllerExtension
  end #end  ControllerHelpers
end # RailsAdmin