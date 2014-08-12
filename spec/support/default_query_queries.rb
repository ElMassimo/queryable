require 'support/models'

class BaseDefaultQuery
  include Queryable
  include Queryable::DefaultQuery
end

class NotOwnersQuery < BaseDefaultQuery
  queryable Owner
end

class NotCustomersQuery < NotOwnersQuery
  queryable Customer
end

class OthersQuery < BaseDefaultQuery
end

class OthersQuery2 < OthersQuery
end

class OthersQuery3 < OthersQuery
  queryable Customer
end
