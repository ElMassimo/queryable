require 'support/models'

class BaseQuery
  include Queryable::ActiveRecord

  queryable false
end

class CustomersQuery
  include Queryable::ActiveRecord

  def initialize(query = nil)
    super
    @queryable = big_spender.queryable
  end
  
  def big_spender
    where(spends: 'a lot')
  end
end

class ShopsQuery < BaseQuery

  scope(:big_spender) { where(spends: 'a lot') }

  def initialize(query = nil)
    super
    @queryable = big_spender.queryable
  end
end
