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
      to = methods.last.is_a?(Hash) && methods.pop[:to] || :queryable
      def_delegators(to == :class ? 'self.class' : to, *methods)
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

  # Internal: Default methods to be delegated to the internal query.
  #
  # Returns an Array with the name of the methods to delegate.
  def self.default_delegated_methods
    Array.instance_methods - Object.instance_methods +
    [:all, :where, :distinct, :group, :having, :includes, :joins, :limit, :offset, :order, :reverse_order] +
    [:==, :as_json, :cache_key, :decorate]
  end
end
