require 'support/queries'

class OwnerQuery
  include Queryable::Chainable

  chain :greedy, :successful, :search
end
