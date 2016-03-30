
require 'rails_admin/config/model'

module RailsAdmin
  module Config
    module ModelExtension
      class InvalidAssociation < ::StandardError
      end
      class ModelNotFound < ::StandardError
      end
      extend ActiveSupport::Concern

      def self.included(base)
        base.class_eval do
          register_instance_option  :nested_has_many_relationships do
            @nested_has_many_relationships ||= begin
              {}.with_indifferent_access
            end
          end
        end
      end

      def display_has_many_nested_association(association_name, options = {})
        raise InvalidAssociation.new("Association name is required") unless association_name.to_s.present?
        association = self.abstract_model.associations.detect{|association| association.name.to_s == association_name.to_s }
        raise InvalidAssociation.new("Association #{association_name} does not exist on model #{self.abstract_model.model_name}") unless association.present?
        options = {
          label: association_name.to_s.humanize,
          link_icon: 'link fa fa-link',
          pjax: true
        }.with_indifferent_access.merge(options||{})
        options[:association] = association
        options[:nested_model_name] = association.options[:class_name]
        raise ModelNotFound unless (nested_abstract_model = RailsAdmin::NestedAbstractModel.new(options[:nested_model_name], OpenStruct.new, association_name))
        raise ModelNotFound if (nested_model_config = nested_abstract_model.config).excluded?
        nested_has_many_relationships[association_name] = OpenStruct.new(options)
      end
    end
  end
end

RailsAdmin::Config::Model.send :include , RailsAdmin::Config::ModelExtension
