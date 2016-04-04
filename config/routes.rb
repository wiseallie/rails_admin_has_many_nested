RailsAdmin::Engine.routes.draw do
  controller 'main' do
    scope ':parent_model_name/:parent_object_id/associations/:association_name' do
      RailsAdmin::Config::Actions.all.select(&:nested_collection).each { |action| match "/#{action.route_fragment}", action: action.action_name, as:  action.action_name , via: action.http_methods, defaults:  action.default_route_fragment_options || {}  }
      # RailsAdmin::Config::Actions.all.select(&:association_nested_action?).each { |action| match "/#{action.route_fragment}", action: action.action_name, as:  action.action_name , via: action.http_methods, defaults:  action.default_route_fragment_options || {}  }
      post '/bulk_action', action: :bulk_action_nested, as: 'bulk_action_nested', defaults: {}
      scope ':id' do
        RailsAdmin::Config::Actions.all.select(&:nested_member).each { |action| match "/#{action.route_fragment}", action: action.action_name, as:  action.action_name, via: action.http_methods, defaults:  action.default_route_fragment_options || {}  }
      end
    end
  end
end
