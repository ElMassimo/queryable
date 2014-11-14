require 'support/models'

class CustomerQuery
  include Queryable

  scope :order_by_expense, -> { desc(:expense_amount) }
  scope :recent, -> { desc(:shopped_at) }
  scope(:shopped_after) {|date| gt(shopped_at: date) }

  delegate_and_chain :awesome, :great, :cool

  def big_expenders_after(date)
    order_by_expense.recent.shopped_after(date)
  end
end

class ShopQuery
  include Queryable

  scope(:order_by_name) { asc(:name) }
  scope :open, -> { where(open: true) }
  scope :located_at, ->(place) { where(location: place) }

  def open_by_name
    open.order_by_name
  end

  def owners
    OwnerQuery.new.owners_of(self)
  end
end

class OwnerQuery
  include Queryable

  scope :success_over, ->(level) { gt(success: level) }
  scope :owners_of, ->(shops) {self.in(_id: shops.distinct(:owner_id)) }

  delegate :order

  def initialize(query=Owner)
    super
  end

  def many
    self.class.name.size
  end

  # Just to illustrate case where you need access to one the Queryable object's methods
  def greedy
    queryable.with_size(shops: many)
  end

  # Simpler query but we don't want to make a scope for `order(:name)`
  def successful
    success_over(9000).order(:name)
  end

  # Complex query that we don't want to define with a scope (we could by injecting self)
  def search(field_values)
    field_values.inject(query) { |user, (field, value)|
      user.where(field => /#{value}/i)
    }
  end
end
