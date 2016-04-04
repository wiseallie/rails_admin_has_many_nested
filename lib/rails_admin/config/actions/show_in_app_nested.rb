require 'rails_admin/config/actions/show_in_app'

module RailsAdmin
  module Config
    module Actions
      class ShowInAppNested < ShowInApp
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          false
        end

        register_instance_option :nested_member do
          true
        end
      end
    end
  end
end
