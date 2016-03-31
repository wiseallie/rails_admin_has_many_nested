require 'rails_admin/adapters/mongoid'
module RailsAdmin
  module Adapters
    module MongoidNested

      def new(params = {})
        ::RailsAdmin::Adapters::Mongoid::AbstractObject.new(parent_object.send(association_name).new(params))
      end

      def get(id)
        ::RailsAdmin::Adapters::Mongoid::AbstractObject.new(parent_object.send(association_name).find(id))
      rescue => e
        raise e if %w(
          Mongoid::Errors::DocumentNotFound
          Mongoid::Errors::InvalidFind
          Moped::Errors::InvalidObjectId
          BSON::InvalidObjectId
        ).exclude?(e.class.to_s)
      end

      def scoped
        parent_object.send(association_name)
      end
    end
  end
end
