require 'queryable/chainable'
require 'queryable/default_query'
require 'queryable/default_scope'

# Public: Provides a way to include all queryable features at once.
module Queryable
  module All

    # Internal: Adds class methods, and default initialization.
    def self.included(base, delegated=[], chainable=[])
      base.send(:include, Chainable, DefaultQuery, DefaultScope, ::Queryable)

      base.delegate *delegated
      base.delegate_and_chain *chainable
    end
  end
end
