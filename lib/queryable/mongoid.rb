require 'queryable'

# Public: Provides default configuration for query objects that decorate a
# Mongoid::Criteria object, delegating the most used methods in Criteria.
module Queryable
  module Mongoid
    # Internal: Adds class methods, and default initialization.
    def self.included(base)
      base.include(Queryable)
      base.delegate *[
        :add_to_set,
        :avg,
        :build,
        :create,
        :delete,
        :destroy,
        :destroy_all,
        :distinct,
        :entries,
        :exists?,
        :explain,
        :find_by,
        :max,
        :min,
        :new,
        :pluck,
        :pull,
        :push,
        :rename,
        :selector,
        :set,
        :sum,
        :update,
        :update_all,
      ]
      base.delegate_and_chain *[
        :and,
        :asc,
        :between,
        :desc,
        :elem_match,
        :exists,
        :gt,
        :gte,
        :in,
        :includes,
        :intersect,
        :limit,
        :lt,
        :lte,
        :ne,
        :nin,
        :none,
        :not,
        :or,
        :order_by,
        :override,
        :skip,
        :union,
        :unscoped,
        :where,
        :with_size,
      ]
    end
  end
end
