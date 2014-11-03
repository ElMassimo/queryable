# Public: Provides a class method that allows a method to be chained.
module Queryable
  module Chainable

    # Internal: Adds class methods, and default initialization.
    def self.included(base)
      base.extend ClassMethods
    end

    # Internal: Contains the Chainable class methods.
    module ClassMethods

      # Public: Makes an existing method chainable by storing its return value
      # as the internal query, and returning the query object itself.
      #
      # Examples:
      #
      #   chain :order_by_name
      #
      #   chain def search(field_values)
      #     field_values.inject(query) { |query, (field, value)|
      #       query.where(field => /#{value}/i)
      #     }
      #   end
      def chain(*names)
        prepend Module.new.tap { |m| Chainable.add_scope_methods(m, names) }
      end
    end

    private

    # Internal: Defines a scope method in the module per each name in the Array.
    #
    # mod - The Module where the scope methods will be added.
    # names - Names of the methods to chain.
    #
    # Returns nothing.
    def self.add_scope_methods(mod, names)
      names.each do |name|
        mod.module_eval Chainable.scope_method(name)
      end
    end

    # Internal: Generates the scope interceptor method.
    #
    # name - Name of the method to convert to a scope.
    #
    # Returns a String with the code of the scope method.
    def self.scope_method(name)
      <<-SCOPE
        def #{name}(*args)
          @queryable = super
          self
        end
      SCOPE
    end
  end
end
