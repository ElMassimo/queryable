require 'support/models'

class BaseQuery
  include Queryable::Mongoid

  queryable false
end

class CustomersQuery
  include Queryable::Mongoid

  def big_spender
    where(spends: 'a lot')
  end
end

class ShopsQuery < BaseQuery
  scope(:big_spender) { where(spends: 'a lot') }
end
