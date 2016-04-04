module RailsAdmin
  module Extensions
    module PunditNested
      # This adapter is for the Pundit[https://github.com/elabs/pundit] authorization library.
      # You can create another adapter for different authorization behavior, just be certain it
      # responds to each of the public methods here.
      class AuthorizationAdapter
        attr_reader :parent_object, :association_name
        # See the +authorize_with+ config method for where the initialization happens.
        def initialize(controller)
          @controller = controller
          @controller.extend ControllerExtension
          @parent_object = @controller.parent_object
          @association_name = @controller.association_name
        end

        # This method is called in every controller action and should raise an exception
        # when the authorization fails. The first argument is the name of the controller
        # action as a symbol (:create, :bulk_delete, etc.). The second argument is the
        # AbstractModel instance that applies. The third argument is the actual model
        # instance if it is available.
        def authorize(action, abstract_model = nil, model_object = nil)
          record = model_object || abstract_model && abstract_model.model
          fail ::Pundit::NotAuthorizedError.new("not allowed to #{action} this #{record}") unless policy(record).send(action_for_pundit(action)) if action
        end

        # This method is called primarily from the view to determine whether the given user
        # has access to perform the action on a given model. It should return true when authorized.
        # This takes the same arguments as +authorize+. The difference is that this will
        # return a boolean whereas +authorize+ will raise an exception when not authorized.
        def authorized?(action, abstract_model = nil, model_object = nil)
          record = model_object || abstract_model && abstract_model.model
          policy(record).send(action_for_pundit(action)) if action
        end

        # This is called when needing to scope a database query. It is called within the list
        # and bulk_delete/destroy actions and should return a scope which limits the records
        # to those which the user can perform the given action on.
        def query(_action, abstract_model)
          begin
            p_scope = begin
              if parent_object.present? && association_name.present?
                @controller.policy_scope!(@controller.send(:pundit_user), parent_object.send(association_name))
              else
                @controller.policy_scope!(@controller.send(:pundit_user), abstract_model.model.all)
              end
            end
          rescue ::Pundit::NotDefinedError
            p_scope = begin
              if parent_object.present? && association_name.present?
                parent_object.send(association_name)
              else
                abstract_model.model.all
              end
            end
          end
          p_scope
        end

        # This is called in the new/create actions to determine the initial attributes for new
        # records. It should return a hash of attributes which match what the user
        # is authorized to create.
        def attributes_for(action, abstract_model)
          record = abstract_model && abstract_model.model
          policy(record).try(:attributes_for, action) || {}
        end


        module ControllerExtension

          # Retrieves the policy scope for the given record.
          #
          # @see https://github.com/elabs/pundit#scopes
          # @param user [Object] the user that initiated the action
          # @param record [Object] the object we're retrieving the policy scope for
          # @return [Scope{#resolve}, nil] instance of scope class which can resolve to a scope
          def policy_scope(user, scope)
            policy_scope = ::Pundit::PolicyFinder.new(scope).scope
            policy_scope.new(user, scope, self).resolve if policy_scope
          end

          # Retrieves the policy scope for the given record.
          #
          # @see https://github.com/elabs/pundit#scopes
          # @param user [Object] the user that initiated the action
          # @param record [Object] the object we're retrieving the policy scope for
          # @raise [NotDefinedError] if the policy scope cannot be found
          # @return [Scope{#resolve}] instance of scope class which can resolve to a scope
          def policy_scope!(user, scope)
            ::Pundit::PolicyFinder.new(scope).scope!.new(user, scope, self).resolve
          end

          # Retrieves the policy for the given record.
          #
          # @see https://github.com/elabs/pundit#policies
          # @param user [Object] the user that initiated the action
          # @param record [Object] the object we're retrieving the policy for
          # @return [Object, nil] instance of policy class with query methods
          def policy(user, record)
            policy = ::Pundit::PolicyFinder.new(record).policy
            policy.new(user, record, self) if policy
          end

          # Retrieves the policy for the given record.
          #
          # @see https://github.com/elabs/pundit#policies
          # @param user [Object] the user that initiated the action
          # @param record [Object] the object we're retrieving the policy for
          # @raise [NotDefinedError] if the policy cannot be found
          # @return [Object] instance of policy class with query methods
          def policy!(user, record)
            ::Pundit::PolicyFinder.new(record).policy!.new(user, record, self)
          end
        end

        private


        def policy(record)
          @controller.policy!(@controller.send(:pundit_user), record)
        rescue ::Pundit::NotDefinedError
          ::ApplicationPolicy.new(@controller.send(:pundit_user), record, @controller)
        end

        def action_for_pundit(action)
          action[-1, 1] == '?' ? action : "#{action}?"
        end
      end
    end
  end
end
