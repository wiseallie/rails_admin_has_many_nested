module RailsAdmin
  module ControllerHelpers
    module ControllerExtension
      class ParentModelNotFound < ::StandardError ;end
      class ParentObjectNotFound < ::StandardError; end
      class HasManyConfigNotFound < ::StandardError; end
      class NestedModelNotFound < ::StandardError ;end
      class NestedObjectNotFound < ::StandardError ;end

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
        has_many_association_config association_name association_label
        )

        def initialize_has_many_nested
          before_action :get_parent_model_and_object_and_nested_model, only: RailsAdmin::Config::Actions.all.select(&:has_many_nested_collection).collect(&:action_name)
          before_action :get_nested_object, only: RailsAdmin::Config::Actions.all.select(&:has_many_nested_member).collect(&:action_name)
          # Does not behave well when there are other before filters
          # because it uses except
          # before_filter :get_model, except: RailsAdmin::Config::Actions.all(:root).collect(&:action_name)
          skip_before_action :get_model
          before_action :_get_model, only: [RailsAdmin::Config::Actions.all(:collection).collect(&:action_name), RailsAdmin::Config::Actions.all(:member).collect(&:action_name)].flatten

          rescue_from ParentModelNotFound do
            flash[:error] = I18n.t('admin.flash.parent_model_not_found', parent_model: @parent_model_name)
            render :error_nested
          end

          rescue_from ParentObjectNotFound do
            flash[:error] = I18n.t('admin.flash.parent_object_not_found', parent_model: @parent_model_name, parent_object_id: params[:parent_object_id])
            render :error_nested
          end

          rescue_from HasManyConfigNotFound do
            flash[:error] = I18n.t('admin.flash.has_many_association_config', parent_model: @parent_model_name, parent_object_id: params[:parent_object_id], association_name: params[:association_name])
            render :error_nested
          end

          rescue_from NestedModelNotFound do
            flash[:error] = I18n.t('admin.flash.nested_model_not_found', parent_model: @parent_model_name, parent_object_id: params[:parent_object_id], association_name: params[:association_name], nested_model: params[:nested_model_name])
            render :error_nested
          end

          rescue_from NestedObjectNotFound do
            flash[:error] = I18n.t('admin.flash.nested_object_not_found', parent_model: @parent_model_name, parent_object_id: params[:parent_object_id], association_name: params[:association_name], nested_model: params[:nested_model_name], nested_object_id: params[:id])
            render :error_nested
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
          helper_method :nested_bindings, :nested_wording_for

        end
      end

      # Try and add more bindings to the current action
      # a controller action is called with
      # instance_eval &@action.controller

      def instance_eval(&block)
        if @action && !@action.bindings[:nested_controller_bindings_set]
          @action = @action.with(nested_bindings({controller: self, nested_controller_bindings_set: true}))
          if @action.has_many_nested_collection || @action.has_many_nested_member
            @page_name = nested_wording_for(:title)
          end
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


      def nested_wording_for(label, action = @action, parent_abstract_model = @parent_abstract_model, parent_object = @parent_object, association_name = @association_name, association_label = @association_label, nested_abstract_model= @nested_abstract_model, nested_object = @nested_object)
        parent_model_config = parent_abstract_model.try(:config)
        nested_model_config = nested_abstract_model.try(:config)

        nested_object = nested_abstract_model && nested_object.is_a?(nested_abstract_model.model) ? nested_object : nil
        action = RailsAdmin::Config::Actions.find(action.to_sym) if action.is_a?(Symbol) || action.is_a?(String)
        capitalize_first_letter I18n.t(
          "admin.actions.#{action.i18n_key}.#{label}_nested",
          parent_model_label: parent_model_config && parent_model_config.label,
          parent_model_label_plural: parent_model_config && parent_model_config.label_plural,
          parent_object_label: parent_model_config && parent_object.try(parent_model_config.object_label_method),
          nested_model_label: nested_model_config && nested_model_config.label,
          nested_model_label_plural: nested_model_config && nested_model_config.label_plural,
          nested_object_label: nested_model_config && nested_object.try(model_config.object_label_method),
          association_label: association_label,
          association_label_singular: association_label.singularize,
          association_name: association_name
        )
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
        @association_label = capitalize_first_letter(@has_many_association_config.label || @association_name.to_s.humanize )
        @parent_properties = @parent_abstract_model.properties
      end

      def get_parent_object
        fail(ParentObjectNotFound) unless (@parent_object = @parent_abstract_model.get(params[:parent_object_id]))
      end

      def get_nested_model
        @model_name = @nested_model_name = @has_many_association_config.association.options[:class_name]
        params[:model_name] = params[:nested_model_name] = to_model_param(@model_name)
        fail(NestedModelNotFound) unless (@abstract_model = @nested_abstract_model =  RailsAdmin::NestedAbstractModel.new(@nested_model_name, @parent_object, @association_name))
        fail(NestedModelNotFound) if (@model_config = @nested_model_config = @nested_abstract_model.config).excluded?
        @properties = @nested_properties =  @nested_abstract_model.properties
      end

      def get_nested_object
        get_parent_model_and_object_and_nested_model
        fail(NestedObjectNotFound) unless (@object = @nested_object = @nested_abstract_model.get(params[:id]))
      end

      private

      def get_new_layout
        "rails_admin/#{request.headers['X-PJAX'] || params['pjax'] ? 'pjax' : 'application'}"
      end
    end #end  ControllerExtension
  end #end  ControllerHelpers
end # RailsAdmin
