require 'support/mock_query'

class Customer

  def all
    MockQuery.new
  end
end

class Shop

  def all
    MockQuery.new
  end
end

class Owner

  def all
    MockQuery.new
  end
end
