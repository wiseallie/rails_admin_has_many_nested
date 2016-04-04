require "rails_admin/config/actions"
require 'rails_admin/config/actions/index_nested'
require 'rails_admin/config/actions/show_nested'
require 'rails_admin/config/actions/show_in_app_nested'
require 'rails_admin/config/actions/history_show_nested'
require 'rails_admin/config/actions/history_index_nested'
require 'rails_admin/config/actions/new_nested'
require 'rails_admin/config/actions/edit_nested'
require 'rails_admin/config/actions/export_nested'
require 'rails_admin/config/actions/delete_nested'
require 'rails_admin/config/actions/bulk_delete_nested'


# for the base association action
RailsAdmin::Config::Actions::Base.send :register_instance_option, :association_nested_action? do
  false
end

RailsAdmin::Config::Actions::Base.send :register_instance_option, :nested_bulkable? do
  bulkable? && (nested_collection? || nested_member?)
end

RailsAdmin::Config::Actions::Base.send :register_instance_option, :nested_member? do
  false
end

RailsAdmin::Config::Actions::Base.send :register_instance_option, :nested_collection? do
  false
end

RailsAdmin::Config::Actions::Base.send :register_instance_option, :default_route_fragment_options do
  {}
end

RailsAdmin::Config::Actions.class_eval do
  class << self
    def all_with_nested(scope = nil, bindings = {})
      if scope.is_a?(Hash)
        bindings = scope
        scope = :all
      end
      scope ||= :all
      actions = init_actions!
      actions = begin
        case scope
        when :all
          actions
        when :root
          actions.select(&:root?)
        when :collection
          actions.select(&:collection?)
        when :bulkable
          actions.select(&:bulkable?)
        when :nested_bulkable
          actions.select(&:nested_bulkable?)
        when :member
          actions.select(&:member?)
        when :nested_collection
          actions.select(&:nested_collection?)
        when :nested_member
          actions.select(&:nested_member?)
        else
          actions.select{|x| s.send(scope)}
        end
      end
      actions = actions.collect { |action| action.with(bindings) }
      bindings[:controller] ? actions.select(&:visible?) : actions
    end
    alias_method_chain :all, :nested

    def nested_collection(key, parent_class = :base, &block)
      add_action key, parent_class, :nested_collection, &block
    end

    def nested_member(key, parent_class = :base, &block)
      add_action key, parent_class, :nested_member, &block
    end
  end
end
