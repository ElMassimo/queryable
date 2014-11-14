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
      attr_accessor :queryable
      alias_method :query, :queryable

      # Internal: Delegates Array and Criteria methods to the internal query.
      delegate *Queryable.default_delegated_methods
    end
  end

  # Public: Initialize a Queryable with a query.
  #
  # query - The internal query to build upon.
  def initialize(query)
    @queryable = query.all
  end

  # Internal: Contains the Queryable class methods.
  module ClassMethods

    # Public: Delegates the specified methods to the internal query.
    def delegate(*methods)
      def_delegators extract_delegation_target(methods), *methods
    end

    # Public: Delegates the specified methods to the internal query, assigns the
    # return value, and returns self.
    def delegate_and_chain(*methods)
      to = extract_delegation_target(methods)
      class_eval methods.map { |name| Queryable.chained_method(name, to) }.join
    end

    # Internal: Extracts the :to option of the arguments, uses the internal
    # query object as the target if no option is provided.
    def extract_delegation_target(args)
      to = args.last.is_a?(Hash) && args.pop[:to] || :queryable
      to == :class ? 'self.class' : to
    end

    # Public: Defines a new method that executes the passed proc or block in
    # the context of the internal query object, and returns self.
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
    # Returns nothing.
    def scope(name, proc=nil, &block)
      define_method(name) do |*args|
        @queryable = queryable.instance_exec *args, &(proc || block)
        self
      end
    end
  end

  # Internal: Generates a method that delegates the call to the an internal
  # object, assigns the return value, and returns self.
  #
  # Returns a String with the code of the method.
  def self.chained_method(name, accessor)
    <<-CHAIN
      def #{name}(*args, &block)
        @queryable = #{accessor}.__send__(:#{name}, *args, &block)
        self
      end
    CHAIN
  end

  # Internal: Default methods to be delegated to the internal query.
  #
  # Returns an Array with the name of the methods to delegate.
  def self.default_delegated_methods
    Array.instance_methods - Object.instance_methods + [:all, :==, :as_json, :decorate]
  end
end
