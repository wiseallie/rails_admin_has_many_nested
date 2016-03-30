require 'rails_admin/config/fields/types/has_many_association'
module RailsAdmin
  module Config
    module Fields
      module Types
        module HasManyNestedAssociationExtension
          extend ActiveSupport::Concern

          def self.included(base)
            base.class_eval do
              base.register_instance_options
            end
          end

          module ClassMethods
            def register_instance_options
              # show nested lists of relationships in the main belongs to list
              # options are :inline, :modal
              register_instance_option :belongs_to_show_in_collection do
                :inline
              end

              # Add another tab for the relationship on the object tabs
              register_instance_option :belongs_to_show_in_object_tabs do
                true
              end

              # Display the has_many relationship list in the object show page
              # options are
              # :default - use the default rails admin style
              # :inline - display the link to expand and show the list inline
              # :has_many_tabs - create special tabs to display the collection of has many relationships
              register_instance_option :belongs_to_show_page_style do
                :default
              end
            end
          end
        end
      end
    end
  end
end

RailsAdmin::Config::Fields::Types::HasManyAssociation.include(RailsAdmin::Config::Fields::Types::HasManyNestedAssociationExtension)
