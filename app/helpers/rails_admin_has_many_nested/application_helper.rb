module RailsAdminHasManyNested
  module ApplicationHelper

    # parent => :root, :collection, :member
    # we only worry about :member actions and fetch actions that have association_nested_action == true
    def menu_for_associations(parent, abstract_model = nil, object = nil, only_icon = false) # perf matters here (no action view trickery)
      if parent == :member
        actions = [RailsAdmin::Config::Actions.find(:index_nested, nested_bindings(parent_abstract_model: parent_abstract_model, parent_object: parent_object, association_name: association_name, nested_abstract_model: nested_abstract_model, nested_object: nested_object, abstract_model:abstract_model , object: object))]
        actions = actions.flatten.compact.select{|action| action.visible?}
        actions.map do |action|
          link_collection = []
          wording = wording_for(:menu, action)
          abstract_model.config.nested_has_many_relationships.each do |association_name, options|
            next unless options[:visible].call(self)
            wording = capitalize_first_letter(options[:label] || association_name)
            url_options = {
              action: action.action_name,
              controller: 'rails_admin/main',
              parent_model_name: abstract_model.try(:to_param),
              parent_object_id: (object.try(:persisted?) && object.try(:id) || nil),
              association_name: association_name
            }
            href = url_for(url_options)
            is_active = @association_name == association_name
            link_collection << %(
            <li title="#{wording if only_icon}" rel="#{'tooltip' if only_icon}" class="icon #{action.key}_#{parent}_link #{'active' if is_active}">
              <a class="#{action.pjax? ? 'pjax' : ''}"  #{action.pjax? ? 'data-pjax-enabled' : ''}  href="#{href}">
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

    # parent => :nested_collection, :nested_member
    # we only worry about :nested_member actions and fetch actions that have association_nested_action == true
    def nested_menu_for_associations(parent, parent_abstract_model, parent_object, only_icon = false) # perf matters here (no action view trickery)
      if parent == :nested_member
        actions = [RailsAdmin::Config::Actions.find(:index_nested, nested_bindings(parent_abstract_model: parent_abstract_model, parent_object: parent_object, association_name: association_name, nested_abstract_model: nested_abstract_model, nested_object: nested_object))]
        actions = actions.flatten.compact.select{|action| action.visible?}
        actions.map do |action|
          link_collection = []
          wording = wording_for(:menu, action)
          abstract_model.config.nested_has_many_relationships.each do |association_name, options|
            next unless options[:visible].call(self)
            wording = capitalize_first_letter(options[:label] || association_name)
            url_options = {
              action: action.action_name,
              controller: 'rails_admin/main',
              parent_model_name: parent_abstract_model.try(:to_param),
              parent_object_id: parent_object.try(:id),
              association_name: association_name,
              pjax_nested: true,
              pjax_nested_list: true
            }
            href = url_for(url_options)
            is_active = @association_name == association_name
            link_collection << %(
            <li title="#{wording if only_icon}" rel="#{'tooltip' if only_icon}" class="icon #{action.key}_#{parent}_link #{'active' if is_active}">
            <a class="#{action.pjax? ? 'pjax' : ''}" data-pjax-nested='true' data-pjax-nested-list-link='true'  data-pjax-container="##{second_random_id}" href="#{href}" >
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

    # parent => :nested_collection, :nested_member
    def nested_menu_for(parent, parent_abstract_model, parent_object, association_name, nested_abstract_model = nil, nested_object = nil, only_icon = false) # perf matters here (no action view trickery)
      actions =  actions(parent, nested_abstract_model, nested_object).select { |a| a.http_methods.include?(:get)}
      actions.collect do |action|
        url_options = {
          action: action.action_name,
          controller: 'rails_admin/main',
          parent_model_name: parent_abstract_model.try(:to_param),
          parent_object_id: parent_object.try(:id),
          association_name: association_name,
          id: nested_object.try(:id).presence
        }
        href = url_for(url_options)
        wording = wording_for(:menu, action)
        is_active = parent_abstract_model ? current_nested_action?(action, association_name, nested_abstract_model, nested_object) : current_action?(action, nested_abstract_model, nested_object)
        %(
        <li title="#{wording if only_icon}" rel="#{'tooltip' if only_icon}" class="icon #{action.key}_#{parent}_link #{'active' if is_active}">
        <a class="#{action.pjax? ? 'pjax' : ''}" href="#{href}">
        <i class="#{action.link_icon}"></i>
        <span#{only_icon ? " style='display:none'" : ''}>#{wording}</span>
        </a>
        </li>
        )
      end.flatten.join.html_safe
    end

    def index_nested_menu_for(parent_abstract_model, parent_object, association_name, nested_abstract_model = nil, nested_object = nil, only_icon = false) # perf matters here (no action view trickery)
      actions = [RailsAdmin::Config::Actions.find(:index_nested, nested_bindings(parent_abstract_model: parent_abstract_model, parent_object: parent_object, association_name: association_name, nested_abstract_model: nested_abstract_model, nested_object: nested_object))]
      actions = actions.flatten.compact.select{|action| action.visible?}
      actions.collect do |action|
        url_options = {
          action: action.action_name,
          controller: 'rails_admin/main',
          parent_model_name: parent_abstract_model.try(:to_param),
          parent_object_id: parent_object.try(:id),
          association_name: association_name,
          id: nested_object.try(:id).presence
        }
        href = url_for(url_options)
        wording = wording_for(:menu, action)
        is_active = parent_abstract_model ? current_nested_action?(action, association_name, nested_abstract_model, nested_object) : current_action?(action, nested_abstract_model, nested_object)
        %(
        <li title="#{wording if only_icon}" rel="#{'tooltip' if only_icon}" class="icon #{action.key}_nested_collection_link #{'active' if is_active}">
        <a  class="#{action.pjax? ? 'pjax' : ''}" href="#{href}">
        <i class="#{action.link_icon}"></i>
        <span#{only_icon ? " style='display:none'" : ''}>#{wording}</span>
        </a>
        </li>
        )
      end.flatten.join.html_safe
    end

    def index_menu_for(abstract_model = nil, object = nil, only_icon = false) # perf matters here (no action view trickery)
      actions = [RailsAdmin::Config::Actions.find(:index, nested_bindings(abstract_model: abstract_model))]
      actions = actions.flatten.compact.select{|action| action.visible?}
      actions.collect do |action|
        wording = wording_for(:menu, action)
        %(
        <li title="#{wording if only_icon}" rel="#{'tooltip' if only_icon}" class="icon #{action.key}_collection_link #{'active' if current_action?(action)}">
        <a class="#{action.pjax? ? 'pjax' : ''}" href="#{url_for(action: action.action_name, controller: 'rails_admin/main', model_name: abstract_model.try(:to_param), id: (object.try(:persisted?) && object.try(:id) || nil))}">
        <i class="#{action.link_icon}"></i>
        <span#{only_icon ? " style='display:none'" : ''}>#{wording}</span>
        </a>
        </li>
        )
      end.join.html_safe
    end

    #(key, abstract_model = nil, object = nil)
    def parent_breadcrumb(action = @action, _acc = [], options = {})
      begin
        (parent_actions ||= []) << action unless action.nested_member
      end while action.breadcrumb_parent && (action = action(*action.breadcrumb_parent)) # rubocop:disable Loop
      options = {
        container_tag: 'ol',
        container_tag_class: 'breadcrumb',
        item_wrapper_tag: 'li',
        item_wrapper_class: '',
        item_wrapper_active_class: 'active',
        link_options: {class: 'pjax'},
        span_options: {}

      }.with_indifferent_access.merge(options)

      c = content_tag(options[:container_tag], class: 'breadcrumb') do
        parent_actions.collect do |a|
          pam = a.send(:eval, 'bindings[:parent_abstract_model]')
          po = a.send(:eval, 'bindings[:parent_object]')
          an = a.send(:eval, 'bindings[:association_name]')
          al = a.send(:eval, 'bindings[:association_label]')
          am = a.send(:eval, 'bindings[:nested_abstract_model]') || a.send(:eval, 'bindings[:abstract_model]')
          o = a.send(:eval, 'bindings[:nested_object]') || a.send(:eval, 'bindings[:object]')
          content_tag(options[:item_wrapper_tag], class: current_action?(a, am, o) ? options[:item_wrapper_active_class] : options[:item_wrapper_class]) do
            crumb = begin
              if !(pam ? current_nested_action?(a, an, am, o) : current_action?(a, am, o))
                if a.http_methods.include?(:get)
                  link_to url_for(action: a.action_name, controller: 'rails_admin/main', model_name: am.try(:to_param), id: (o.try(:persisted?) && o.try(:id) || nil)), options[:link_options]  do
                    pam ? nested_wording_for(:breadcrumb, a, pam, po, an , al, am, o) : wording_for(:breadcrumb, a, am, o)
                  end
                else
                  content_tag(:span, pam ? nested_wording_for(:breadcrumb, a, pam, po, an , al, am, o) : wording_for(:breadcrumb, a, am, o), options[:span_options])
                end
              else
                pam ? nested_wording_for(:breadcrumb, a, pam, po, an , al, am, o) : wording_for(:breadcrumb, a, am, o)
              end
            end
            crumb
          end
        end.reverse.join.html_safe
      end
      c
    end

    def nested_breadcrumb(action = @action, _acc = [], options = {})
      begin
        (parent_actions ||= []) << action
      end while  action.breadcrumb_parent && (action = action(*action.breadcrumb_parent)) # rubocop:disable Loop
      options = {
        container_tag: 'ol',
        container_tag_class: 'breadcrumb',
        item_wrapper_tag: 'li',
        item_wrapper_class: '',
        item_wrapper_active_class: 'active',
        link_options: {class: 'pjax'},
        span_options: {}

      }.with_indifferent_access.merge(options)

      c = content_tag(options[:container_tag], class: 'breadcrumb') do
        parent_actions.collect do |a|
          pam = a.send(:eval, 'bindings[:parent_abstract_model]')
          po = a.send(:eval, 'bindings[:parent_object]')
          an = a.send(:eval, 'bindings[:association_name]')
          al = a.send(:eval, 'bindings[:association_label]')
          am = a.send(:eval, 'bindings[:nested_abstract_model]') || a.send(:eval, 'bindings[:abstract_model]')
          o = a.send(:eval, 'bindings[:nested_object]') || a.send(:eval, 'bindings[:object]')
          content_tag(options[:item_wrapper_tag], class: current_action?(a, am, o) ? options[:item_wrapper_active_class] : options[:item_wrapper_class]) do
            crumb = begin
              if !(pam ? current_nested_action?(a, an, am, o) : current_action?(a, am, o))
                if a.http_methods.include?(:get)
                  link_to url_for(action: a.action_name, controller: 'rails_admin/main', model_name: am.try(:to_param), id: (o.try(:persisted?) && o.try(:id) || nil)), options[:link_options]  do
                    pam ? nested_wording_for(:breadcrumb, a, pam, po, an , al, am, o) : wording_for(:breadcrumb, a, am, o)
                  end
                else
                  content_tag(:span, pam ? nested_wording_for(:breadcrumb, a, pam, po, an , al, am, o) : wording_for(:breadcrumb, a, am, o), options[:span_options])
                end
              else
                pam ? nested_wording_for(:breadcrumb, a, pam, po, an , al, am, o) : wording_for(:breadcrumb, a, am, o)
              end
            end
            crumb
          end
        end.reverse.join.html_safe
      end
      c
    end

    def current_nested_action?(action, association_name = @association_name, nested_abstract_model= @nested_abstract_model, nested_object = @nested_object)
      @action.custom_key == action.custom_key &&
      nested_abstract_model.try(:to_param) == @nested_abstract_model.try(:to_param) &&
      (@nested_object.try(:persisted?) ? @nested_object.id == nested_object.try(:id) : !nested_object.try(:persisted?)) &&
      @association_name == association_name
    end

    def nested_bulk_menu(abstract_model = @abstract_model)
      actions = actions(:nested_bulkable, abstract_model)
      return '' if actions.empty?
      content_tag :li, class: 'dropdown', style: 'float:right' do
        content_tag(:a, class: 'dropdown-toggle', data: {toggle: 'dropdown'}, href: '#') { t('admin.misc.bulk_menu_title').html_safe + ' ' + '<b class="caret"></b>'.html_safe } +
        content_tag(:ul, class: 'dropdown-menu', style: 'left:auto; right:0;') do
          actions.collect do |action|
            content_tag :li do
              link_to nested_wording_for(:bulk_link, action), '#', onclick: "jQuery('#bulk_action').val('#{action.action_name}'); jQuery('#bulk_form').submit(); return false;"
            end
          end.join.html_safe
        end
      end.html_safe
    end

    def random_id
      @random_id ||= SecureRandom.hex
    end

    def second_random_id
      @second_random_id ||= SecureRandom.hex
    end

  end #end  ApplicationHelper
end #end  RailsAdminHasManyNested

require  'rails_admin/application_helper'
RailsAdmin::ApplicationHelper.send(:include, RailsAdminHasManyNested::ApplicationHelper)
