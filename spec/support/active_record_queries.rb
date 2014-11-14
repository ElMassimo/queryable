require 'support/models'

class BaseQuery
  include Queryable::ActiveRecord

  queryable false
end

class CustomersQuery
  include Queryable::ActiveRecord

  default_scope :big_spender

  def big_spender
    where(spends: 'a lot')
  end
end

class ShopsQuery < BaseQuery

  scope(:big_spender) { where(spends: 'a lot') }

  default_scope :big_spender
end
