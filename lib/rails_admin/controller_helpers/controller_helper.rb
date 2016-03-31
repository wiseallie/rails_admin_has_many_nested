module RailsAdmin
  module ControllerHelpers
    module ControllerHelper

      # parent => :root, :collection, :member
      # we only worry about :member actions and fetch actions that have association_nested_action == true
      def menu_for_associations(parent, abstract_model = nil, object = nil, only_icon = false) # perf matters here (no action view trickery)
        if parent == :member
          actions =  actions(:all, abstract_model, object).select { |a| a.association_nested_action? && a.http_methods.include?(:get)}
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

      # parent => :has_many_nested_collection, :has_many_nested_member
      # we only worry about :has_many_nested_member actions and fetch actions that have association_nested_action == true
      def nested_menu_for_associations(parent, parent_abstract_model, parent_object, only_icon = false) # perf matters here (no action view trickery)
        if parent == :has_many_nested_member
          actions =  actions(:all, abstract_model, object).select { |a| a.association_nested_action? && a.http_methods.include?(:get)}
          actions.collect do |action|
            link_collection = []
            wording = wording_for(:menu, action)
            abstract_model.config.nested_has_many_relationships.each do |association_name, options|
              wording = capitalize_first_letter(options[:label] || association_name)
              url_options = {
                action: action.action_name,
                controller: 'rails_admin/main',
                parent_model_name: parent_abstract_model.try(:to_param),
                parent_object_id: parent_object.try(:id),
                association_name: association_name,
                pjax_nested: true
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

      # parent => :has_many_nested_collection, :has_many_nested_member
      def nested_menu_for(parent, parent_abstract_model, parent_object, association_name, abstract_model = nil, object = nil, only_icon = false) # perf matters here (no action view trickery)
        actions =  actions(:all, abstract_model, object).select { |a| a.send(parent) && a.http_methods.include?(:get)}
        actions.collect do |action|
            url_options = {
              action: action.action_name,
              controller: 'rails_admin/main',
              parent_model_name: parent_abstract_model.try(:to_param),
              parent_object_id: parent_object.try(:id),
              association_name: association_name,
              id: (object.try(:persisted?) && parent_object.try(:id) || nil),
            }
            href = url_for(url_options)
            wording = wording_for(:menu, action)
          %(
            <li title="#{wording if only_icon}" rel="#{'tooltip' if only_icon}" class="icon #{action.key}_#{parent}_link #{'active' if current_action?(action) && association_name == params[:association_name]}">
              <a class="#{action.pjax? ? 'pjax' : ''}" href="#{href}">
                <i class="#{action.link_icon}"></i>
                <span#{only_icon ? " style='display:none'" : ''}>#{wording}</span>
              </a>
            </li>
          )
        end.flatten.join.html_safe
      end

      #(key, abstract_model = nil, object = nil)
      def parent_breadcrumb(action = @action, _acc = [])
        begin
          (parent_actions ||= []) << action
        end while action.breadcrumb_parent && (action = action(*action.breadcrumb_parent)) # rubocop:disable Loop
        content_tag(:ol, class: 'breadcrumb') do
          parent_actions.collect do |a|
            am = a.send(:eval, 'bindings[:abstract_model]')
            o = a.send(:eval, 'bindings[:object]')
            content_tag(:li, class: current_action?(a, am, o) && 'active') do
              crumb = begin
                if !current_action?(a, am, o)
                  if a.http_methods.include?(:get)
                    link_to url_for(action: a.action_name, controller: 'rails_admin/main', model_name: am.try(:to_param), id: (o.try(:persisted?) && o.try(:id) || nil)), class: 'pjax' do
                      wording_for(:breadcrumb, a, am, o)
                    end
                  else
                    content_tag(:span, wording_for(:breadcrumb, a, am, o))
                  end
                else
                  wording_for(:breadcrumb, a, am, o)
                end
              end
              crumb
            end
          end.reverse.join.html_safe
        end
      end

    end #end  ControllerHelper
  end #end  ControllerHelpers
end # RailsAdmin
