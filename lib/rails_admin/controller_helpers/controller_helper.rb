module RailsAdmin
  module ControllerHelpers
    module ControllerHelper
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
        parent_model parent_model_name parent_abstract_model parent_model_config  parent_properties
        model model_name abstract_model model_config  properties
        nested_model nested_model_name nested_abstract_model nested_model_config  nested_properties
        has_many_association_config
        )

        def initialize_has_many_nested

          attr_accessor *ATTR_ACCESSORS_TO_DEFINE
          prepend_before_action :get_nested_object, only: RailsAdmin::Config::Actions.all.select(&:has_many_nested_member).collect(&:action_name)
          prepend_before_action :get_parent_model_and_object_and_nested_model, only: RailsAdmin::Config::Actions.all.select(&:has_many_nested_collection).collect(&:action_name)

          # Does not behave well when there are other before filters
          # because it uses except
          # before_filter :get_model, except: RailsAdmin::Config::Actions.all(:root).collect(&:action_name)
          skip_before_filter :get_model
          prepend_before_action :_get_model, only: [RailsAdmin::Config::Actions.all(:root).collect(&:action_name), RailsAdmin::Config::Actions.all(:member).collect(&:action_name)].flatten

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

          helper_method :menu_for_with_nested_actions, :menu_for_associations
          helper_method *ATTR_ACCESSORS_TO_DEFINE
          hide_action *ATTR_ACCESSORS_TO_DEFINE
        end
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
        params[:model_name] = to_model_param(@model_name )
      end

      def get_nested_object
        get_parent_model_and_object_and_nested_model
        fail(RailsAdmin::ObjectNotFound) unless (@object = @nested_object = @nested_abstract_model.get(params[:id]))
      end

      # parent => :root, :collection, :member
      # we only worry about :member actions and fetch actions that have association_nested_action == true
      def menu_for_associations(parent, abstract_model = nil, object = nil, only_icon = false) # perf matters here (no action view trickery)
        if parent == :member
          actions =  RailsAdmin::Config::Actions.all(:all, controller: self.try(:controller)||self, abstract_model: abstract_model, object: object).select { |a| a.association_nested_action? && a.http_methods.include?(:get)}
          actions.collect do |action|
            link_collection = []
            wording = wording_for(:menu, action)
            abstract_model.config.nested_has_many_relationships.each do |association_name, options|
              wording = capitalize_first_letter(options[:label] || association_name)
              url_options = {
                action: action.action_name,
                controller: 'rails_admin/main',
                parent_model_name: abstract_model.try(:to_param),
                parent_object_id: (object.try(:persisted?) && object.try(:id) || nil),
                association_name: association_name
              }
              href = url_for(url_options)
              link_collection << %(
                <li title="#{wording if only_icon}" rel="#{'tooltip' if only_icon}" class="icon #{action.key}_#{parent}_link #{'active' if current_action?(action) && association_name.to_s == params[:association_name].to_s}">
                  <a class="#{action.pjax? ? 'pjax' : ''}" href="#{href}">
                    <i class="#{options[:link_icon]||action.link_icon}"></i>
                    <span#{only_icon ? " style='display:none'" : ''}>#{wording}</span>
                  </a>
                </li>
              )
            end
            link_collection
          end.compact.join.html_safe
        end
      end

      # parent => :root, :collection, :member
      def has_many_nested_menu_for(parent, abstract_model = nil, object = nil, only_icon = false) # perf matters here (no action view trickery)
        actions =  RailsAdmin::Config::Actions.all(parent, controller: self.try(:controller)||self, abstract_model: abstract_model, object: object).select { |a| a.http_methods.include?(:get) }
        actions.collect do |action|
          if parent.to_s == "member" && action.is_has_many_nested_action?
            kollection = []
            abstract_model.config.nested_has_many_relationships.each do |association_name, options|
              wording = capitalize_first_letter(options[:label] || association_name)
              nested_abstract_model =  RailsAdmin::NestedAbstractModel.new(options[:nested_model_name], object, association_name)
              nested_model_config = nested_abstract_model.config

              url_options = {
                action: action.action_name,
                controller: 'rails_admin/main',
                model_name: abstract_model.try(:to_param),
                id: (object.try(:persisted?) && object.try(:id) || nil),
                association_name: association_name,
                nested_url_options: {
                  action: :index,
                  controller: 'rails_admin/main',
                  parent_model_name: abstract_model.try(:to_param),
                  parent_object_id: (object.try(:persisted?) && object.try(:id) || nil),
                  association_name: association_name,
                  model_name: options[:abstract_model].try(:to_param),
                  pjax: true
                }
              }
              href = url_for(url_options)
              kollection << %(
              <li title="#{wording if only_icon}" rel="#{'tooltip' if only_icon}" class="icon #{action.key}_#{parent}_link #{'active' if current_action?(action) && association_name.to_s == params[:association_name].to_s}">
              <a class="#{action.pjax? ? 'pjax' : ''}" href="#{href}">
              <i class="#{options[:link_icon]||action.link_icon}"></i>
              <span#{only_icon ? " style='display:none'" : ''}>#{wording}</span>
              </a>
              </li>
              )
            end
            kollection
          else
            wording = wording_for(:menu, action)
            %(
            <li title="#{wording if only_icon}" rel="#{'tooltip' if only_icon}" class="icon #{action.key}_#{parent}_link #{'active' if current_action?(action)}">
            <a class="#{action.pjax? ? 'pjax' : ''}" href="#{url_for(action: action.action_name, controller: 'rails_admin/main', model_name: abstract_model.try(:to_param), id: (object.try(:persisted?) && object.try(:id) || nil))}">
            <i class="#{action.link_icon}"></i>
            <span#{only_icon ? " style='display:none'" : ''}>#{wording}</span>
            </a>
            </li>
            )
          end
        end.flatten.join.html_safe
      end

      #
      # def nested_menu_for_with_has_many_nested(parent, parent_abstract_model, parent_object, association_name, abstract_model , object = nil, only_icon = false) # perf matters here (no action view trickery)
      #   actions = actions(parent, abstract_model, object).select { |a| a.http_methods.include?(:get) }
      #   all_actions = actions.collect do |action|
      #     nested_action_menu_for_with_has_many_nested(parent, parent_abstract_model, parent_object, association_name, abstract_model, object, only_icon)
      #   end.flatten.join.html_safe
      # end


      # parent => :root, :collection, :member
      # def nested_action_menu_for_with_has_many_nested(parent, parent_abstract_model, parent_object, association_name, abstract_model, object, only_icon, options) # perf matters here (no action view trickery)
      #     wording = capitalize_first_letter(options[:label] || association_name)
      #     url_options = {
      #       action: :index,
      #       controller: 'rails_admin/main',
      #       parent_model_name: parent_abstract_model.try(:to_param),
      #       parent_object_id: (parent_object.try(:persisted?) && parent_object.try(:id) || nil),
      #       association_name: association_name,
      #       model_name: abstract_model.try(:to_param)
      #     }
      #     url_options[:id] = object.try(:id) if object.try(:persisted?) && object.try(:id)
      #     href = url_for(url_options)
      #     return %(
      #       <li title="#{wording if only_icon}" rel="#{'tooltip' if only_icon}" class="icon index_#{parent}_link #{'active' if  association_name.to_s == params[:association_name].to_s}">
      #         <a class="#{options[:pjax] ? 'pjax' : ''}" href="#{href}">
      #           <i class="#{options[:link_icon]}"></i>
      #           <span#{only_icon ? " style='display:none'" : ''}>#{wording}</span>
      #         </a>
      #       </li>
      #     )
      # end

      private

      def get_new_layout
        "rails_admin/#{request.headers['X-PJAX'] || params['pjax'] ? 'pjax' : 'application'}"
      end
    end #end  ControllerHelper
  end #end  ControllerHelpers
end # RailsAdmin
