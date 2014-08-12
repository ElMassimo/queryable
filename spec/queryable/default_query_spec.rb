require 'spec_helper'
require './lib/queryable'
require './lib/queryable/default_query'
require 'support/default_query_queries'

describe Queryable do

  Given(:other) { double('other') }
  Given(:owner) { double('owner') }
  Given(:customer) { double('customer') }

  Given {
    [other, owner, customer].each do |query|
      allow(query).to receive(:all).and_return(query)
    end
  }

  When(:query) { query_class.new.query }

  context 'when non inferable query' do
    Given(:query_class) { NotOwnersQuery }
    Given do
      expect(Owner).to receive(:all).and_return(owner)
    end
    Then { query == owner }
  end

  context 'when non inferable query has subclass that specifies it' do
    Given(:query_class) { NotCustomersQuery }
    Given do
      expect(Customer).to receive(:all).and_return(customer)
    end
    Then { query == customer }
  end

  context 'when inferable query' do
    Given(:query_class) { OthersQuery }
    Given do
      expect(Other).to receive(:all).and_return(other)
    end
    Then { query == other }
  end

  context 'when inferable query has subclass that does not specify it' do
    Given(:query_class) { OthersQuery2 }
    Given do
      expect(Other).to receive(:all).and_return(other)
    end
    Then { query == other }
  end

  context 'when inferable query has subclass that specifies it' do
    Given(:query_class) { OthersQuery3 }
    Given do
      expect(Customer).to receive(:all).and_return(customer)
    end
    Then { query == customer }
  end
end
