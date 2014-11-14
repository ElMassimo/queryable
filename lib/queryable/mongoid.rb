require 'queryable/chainable'
require 'queryable/default_query'
require 'queryable/default_scope'

# Public: Provides default configuration for query objects that decorate a
# Mongoid::Criteria object, delegating the most used methods in Criteria.
module Queryable
  module Mongoid

    DELEGATED_METHODS = [
      :avg, :max, :min, :sum, :exists?, :set, :pull, :push, :add_to_set,
      :find_by, :build, :create, :destroy, :destroy_all, :update, :update_all,
      :delete, :pluck, :distinct, :selector, :rename, :entries, :new, :explain
    ]

    CHAINABLE_METHODS = [
      :where, :ne, :nin, :gt, :gte, :in, :lt, :lte, :between, :and, :or, :not,
      :intersect, :override, :union, :exists, :elem_match, :with_size,
      :none, :unscoped, :includes, :order_by, :asc, :desc, :skip, :limit
    ]

    # Internal: Adds class methods, and default initialization.
    def self.included(base)
      base.include Chainable, DefaultQuery, DefaultScope, ::Queryable

      base.delegate *DELEGATED_METHODS
      base.delegate_and_chain *CHAINABLE_METHODS
    end
  end
end
