# Public: Provides default initialization for query objects, most objects are
# mapped to a collection or table, the default query takes all of them.
module Queryable
  module DefaultQuery

    # Internal: Adds class methods, and default initialization.
    def self.included(base)
      base.extend ClassMethods
    end

    def initialize(query=self.class.default_query)
      super
    end

    module ClassMethods

      # Public: Sets the default table or collection for this query object.
      #
      # collection - A model or static query.
      def queryable(collection)
        @queryable_class = collection
      end

      # Internal: Default query for the object, can be overriden by subclasses.
      #
      # Returns a criteriable or chainable query of some sort.
      def default_query
        queryable_class.all
      end

      # Internal: The default table or collection for this query object.
      # Provides a default based on a convention of the query object name.
      def queryable_class
        @queryable_class ||= if superclass.respond_to?(:queryable_class)
          superclass.queryable_class || Object.const_get(name.gsub('sQuery', ''))
        end
      end
    end
  end
end
