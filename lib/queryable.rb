# Public: Mixin that adds Queryable functionality to a plain ruby object.
# A Queryable manages an internal query object, and defines chainable methods
# that interact with the query object, modifying its value.
# It's designed to work well with both Mongoid and ActiveRecord.
#
# Examples
#
#   class PersonQuery
#     include Queryable
#     scope(:too_damn_high) { where(:level.gt => 9000) }
#   end
#'
module Queryable

  # Internal: Adds class methods, a query accessor, and method delegation.
  def self.included(base)
    base.extend Forwardable
    base.extend ClassMethods
    base.class_eval do
      # Public: Gets/Sets the internal query.
      attr_accessor :query

      # Internal: Delegates Array and Criteria methods to the internal query.
      delegate *Queryable.default_delegated_methods
    end
  end

  # Public: Initialize a Queryable with a query.
  #
  # query - The internal query to build upon.
  def initialize(query)
    @query = query.all
  end

  # Internal: Contains the Queryable class methods.
  module ClassMethods

    # Public: Delegates the specified methods to the internal query.
    def delegate(*methods)
      methods.last.is_a?(Hash) ? super : def_delegators(:query, *methods)
    end

    # Public: Defines a new scope method, or makes an existing method chainable.
    #
    # name - Name of the scope to define for this Queryable.
    #
    # proc - An optional proc or lambda to be executed in the context of the
    #        the current query.
    #
    # block - An optional block to be executed in the context of the current
    #         query.
    #
    # Yields the arguments given to the scope when invoked, generally none.
    #
    # Examples
    #
    #   scope :active, ->{ where(status: 'active') }
    #
    #   scope(:recent) { desc(:created_at) }
    #
    #   scope :of_brand do |brand|
    #     where(_type: "#{brand}ExtremelyFastRacingCar")
    #   end
    #
    #   scope def search(field_values)
    #     field_values.inject(query) { |query, (field, value)|
    #       query.where(field => /#{value}/i)
    #     }
    #   end
    #
    # Returns nothing.
    def scope(name, proc=nil, &block)
      if method_defined?(name)
        scope_method(name)
      else
        define_scope(name, proc || block)
      end
    end

    private

    # Internal: Defines a new method that executes the passed proc or block in
    # the context of the internal query object, and returns self.
    def define_scope(name, proc)
      define_method(name) do |*args|
        @query = query.instance_exec *args, &proc
        self
      end
    end

    # Public: Makes an existing method chainable by intercepting the call, and
    # storing the result as the internal query, and returning self.
    def scope_method(name)
      prepend Module.new.tap { |s| s.module_eval Queryable.scope_method(name) }
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
        @query = super
        self
      end
    SCOPE
  end

  # Internal: Default methods to be delegated to the internal query.
  #
  # Returns an Array with the name of the methods to delegate.
  def self.default_delegated_methods
    Array.instance_methods - Object.instance_methods +
    [:all, :where, :distinct, :group, :having, :includes, :joins, :limit, :offset, :order, :reverse_order] +
    [:==, :as_json, :cache_key, :decorate]
  end
end
