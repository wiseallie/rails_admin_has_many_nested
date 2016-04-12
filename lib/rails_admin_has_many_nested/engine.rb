module RailsAdminHasManyNested
  class Engine < ::Rails::Engine
    ActionDispatch::Callbacks.to_prepare do
      RailsAdmin::MainController.class_eval do
        include RailsAdmin::Controllers::Concerns::ApplicationConcern
      end
    end
  end
end
