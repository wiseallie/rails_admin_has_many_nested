require 'rails_admin/adapters/active_record'
module RailsAdmin
  module Adapters
    module ActiveRecordNested

      def new(params = {})
        AbstractObject.new(parent_object.send(:association_name).new(params))
      end

      def get(id)
        return unless object = parent_object.send(:association_name).where(primary_key => id).first
        AbstractObject.new object
      end

      def scoped
        parent_object.send(:association_name)
      end
    end
  end
end
