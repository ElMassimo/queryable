require 'queryable/version'

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

  # Public: Initialize a query object using the specified query.
  #
  # query - The internal query to build upon.
  def initialize(query = nil)
    @queryable = query || self.class.default_query
  end

  # Internal: Contains the Queryable class methods.
  module ClassMethods
    # Public: Wraps a query or query object in an instance of this class.
    def wrap(query)
      new(query.responds_to?(:queryable) ? query.queryable : query)
    end

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

    # Internal: Default query for the object, can be overriden by subclasses.
    #
    # Returns a criteriable or chainable query of some sort.
    def default_query
      queryable_class.all
    end

    # Internal: Attempts to use the parent query collection (if any), and
    # provides a default based on a convention of the query object name.
    def queryable_class
      unless defined?(@queryable_class)
        @queryable_class = superclass.respond_to?(:queryable_class) && superclass.queryable_class ||
          Object.const_get(name.sub('sQuery', '').sub('iesQuery', 'y'))
      end
      @queryable_class
    end

    # Public: Sets the default table or collection for this query object.
    #
    # collection - A model or static query.
    def queryable(collection)
      @queryable_class = collection
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
      define_method(name) { |*args, **kwargs|
        self.class.new queryable.instance_exec(*args, **kwargs, &(proc || block))
      }
    end
  end

  # Internal: Generates a method that returns a new query object wrapping the
  # result of applying that named method to the underlying query.
  #
  # Returns a String with the code of the method.
  def self.chained_method(name, accessor)
    <<-CHAIN
      def #{name}(...)
        self.class.new #{accessor}.#{name}(...)
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
