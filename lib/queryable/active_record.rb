require 'queryable'

# Public: Provides default configuration for query objects that decorate a
# ActiveRecord::Relation object, delegating the most used methods.
module Queryable
  module ActiveRecord
    # Internal: Adds class methods, and default initialization.
    def self.included(base)
      base.include Queryable
      base.delegate *[
        :average,
        :build,
        :create,
        :entries,
        :exists?,
        :explain,
        :find_by,
        :maximum,
        :minimum,
        :new,
        :pluck,
        :sum,
      ]
      base.delegate_and_chain *[
        :bind,
        :create_with,
        :distinct,
        :eager_load,
        :extending,
        :from,
        :group,
        :having,
        :includes,
        :joins,
        :limit,
        :lock,
        :none,
        :not,
        :offset,
        :only,
        :order,
        :preload,
        :readonly,
        :references,
        :reorder,
        :reverse_order,
        :select,
        :uniq,
        :unscope,
        :unscoped,
        :where,
      ]
    end
  end
end
