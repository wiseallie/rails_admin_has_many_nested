module RailsAdminHasManyNested
  class Engine < ::Rails::Engine

    initializer :config_reload_on_development do
      load_extensions_for_has_many_nested
    end

    config.after_initialize do
      load_extensions_for_has_many_nested
    end

    def load_extensions_for_has_many_nested
      unless RailsAdmin::ApplicationController.included_modules.include?(RailsAdmin::Controllers::Concerns::ApplicationConcern)
        RailsAdmin::ApplicationController.send(:include, RailsAdmin::Controllers::Concerns::ApplicationConcern)
      end
    end
  end
end
