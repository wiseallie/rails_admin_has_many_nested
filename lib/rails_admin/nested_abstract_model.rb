require 'rails_admin/support/datetime'
require 'rails_admin/abstract_model'

module RailsAdmin
  class NestedAbstractModel < AbstractModel
    attr_reader :parent_object, :association_name

    class << self
      # NOT SURE WHY THIS IS LIKE THIS!!!!  COPIED AND OVERWRITTEN DIRECLTY INTO THIS CLASS
      def new(model_or_model_name, parent_object, association_name)
        model_or_model_name = model_or_model_name.constantize unless model_or_model_name.is_a?(Class)
        (am = old_new(model_or_model_name, parent_object, association_name)).model && am.adapter ? am : nil
      rescue LoadError, NameError
        puts "[RailsAdmin] Could not load model #{m}, assuming model is non existing. (#{$ERROR_INFO})" unless Rails.env.test?
        nil
      end
    end

    def initialize(model_or_model_name, parent_object, association_name)
      @parent_object = parent_object
      @association_name = association_name
      super(model_or_model_name)
    end

    def where(conditions)
      @parent_object.send(association_name).where(conditions)
    end

    private

    def initialize_active_record
      super
      require 'rails_admin/adapters/active_record_nested'
      extend Adapters::ActiveRecordNested
    end

    def initialize_mongoid
      super
      require 'rails_admin/adapters/mongoid_nested'
      extend Adapters::MongoidNested
    end

  end
end
