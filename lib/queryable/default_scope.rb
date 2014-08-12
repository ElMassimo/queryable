# Public: Allows to define default scopes in query objects, and inherit them in
# query object subclasses.
module Queryable
  module DefaultScope

    # Internal: Adds class methods, and default initialization.
    def self.included(base)
      base.extend ClassMethods
    end

    def initialize(*args)
      super
      apply_default_scopes
    end

    private

    # Internal: Applies all the default scopes to this query object.
    def apply_default_scopes
      self.class.default_scopes.each { |scope| apply_default_scope(scope) }
    end

    # Internal: Applies a default scope to this query object.
    #
    # scope - A method name Symbol, or a Proc.
    #
    def apply_default_scope(scope)
      scope.is_a?(Proc) ? instance_exec(&scope) : send(scope)
    end

    module ClassMethods

      # Public: Allows a class to set a default scope. Default scopes are
      # chainable with inheritance, so a subclass also picks up the default
      # scopes of the parent class.
      #
      # scope - A method name Symbol, or a Proc.
      def default_scope(scope)
        @default_scope = scope
      end

      # Internal: Returns the default scopes of the parent query objects.
      def parent_scopes
        superclass.respond_to?(:default_scopes) ? superclass.default_scopes : []
      end

      # Internal: Returns the default scopes that should be applied.
      def default_scopes
        @default_scopes ||= (parent_scopes + [@default_scope]).compact
      end
    end
  end
end
