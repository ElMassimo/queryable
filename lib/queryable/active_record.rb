require 'queryable/chainable'
require 'queryable/default_query'
require 'queryable/default_scope'

# Public: Provides default configuration for query objects that decorate a
# ActiveRecord::Relation object, delegating the most used methods.
module Queryable
  module ActiveRecord

    DELEGATED_METHODS = [
      :average, :maximum, :minimum, :sum, :exists?, :find_by, :build, :create,
      :pluck, :entries, :new, :explain
    ]

    CHAINABLE_METHODS = [
      :where, :bind, :create_with, :distinct, :eager_load, :extending, :from,
      :group, :having, :includes, :joins, :limit, :lock, :none, :offset, :order,
      :preload, :readonly, :references, :reorder, :reverse_order, :select,
      :uniq, :not, :unscoped, :unscope, :only
    ]

    # Internal: Adds class methods, and default initialization.
    def self.included(base)
      base.send(:include, Chainable, DefaultQuery, DefaultScope, ::Queryable)

      base.delegate *DELEGATED_METHODS
      base.delegate_and_chain *CHAINABLE_METHODS
    end
  end
end
