require 'active_support/concern'
require 'active_support/core_ext/module/delegation'

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
#
module Queryable
  extend ActiveSupport::Concern

  included do
    # Public: Gets/Sets the internal query.
    attr_accessor :query

    delegate *delegated_methods, to: :query
  end

  # Public: Initialize a Queryable with a query.
  #
  # query - The internal query to build upon.
  def initialize(query)
    @query = query.all
  end

  # Public: Convenience setter for the internal query that returns self. The
  # query is set to the value returned by the block. Useful when you need to
  # access the context of the Queryable in addition to the query.
  #
  # block - A block that returns the new value of the internal query.
  #
  # Yields the internal query, which can be used to build upon.
  #  def search(query)
  #
  # Examples
  #
  #   # Accessing a constant in the Queryable object context.
  #   LATEST_COUNT = 10
  #   def latest
  #     define_query {|query| query.limit(LATEST_COUNT) }
  #   end
  #
  #   # We use it because the last method we chain does not return self.
  #   def recent_by_name
  #     define_query { recent.order(:name) }
  #   end
  #
  #   # Extracted from a scope for clarity.
  #   def search(field_values)
  #     define_query do |users|
  #       field_values.inject(users) { |users, (field, value)|
  #         users.where(field => /#{value}/i)
  #       }
  #     end
  #   end
  #
  # Returns the Queryable object itself (self).
  def define_query
    @query = yield(query)
    self
  end

  # Internal: Contains the Queryable class methods.
  module ClassMethods
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
        @query = query.instance_exec *args, &(proc || block)
        self
      end
    end

    # Internal: Methods to be delegated to the internal query. Method
    # can be safely overriden to add or remove methods to delegate.
    #
    # Returns an Array with the name of the methods to delegate.
    def delegated_methods
      Array.instance_methods - Object.instance_methods +
      [:all, :where, :distinct, :group, :having, :includes, :joins, :limit, :offset, :order, :reverse_order] +
      [:==, :as_json, :cache_key, :decorate]
    end
  end
end
