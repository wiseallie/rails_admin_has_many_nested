require 'rails_admin/config/actions'

# for the base association action
RailsAdmin::Config::Actions::Base.send :register_instance_option, :association_nested_action? do
  false
end

RailsAdmin::Config::Actions::Base.send :register_instance_option, :has_many_nested_member do
  false
end

RailsAdmin::Config::Actions::Base.send :register_instance_option, :has_many_nested_collection do
  false
end

RailsAdmin::Config::Actions::Base.send :register_instance_option, :default_route_fragment_options do
  {}
end
