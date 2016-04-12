module RailsAdminHasManyNested
  class Engine < ::Rails::Engine
    ActionDispatch::Callbacks.to_prepare do
      RailsAdmin::MainController.send(:include, RailsAdmin::Controllers::Concerns::ApplicationConcern)
    end
  end
end
