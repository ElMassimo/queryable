require 'spec_helper'
require './lib/queryable'
require './lib/queryable/mongoid'
require 'support/mongoid_queries'

describe Queryable::Mongoid do

  Given(:criteria) { double('criteria') }
  Given(:other_criteria) { double('criteria') }
  When(:queryable) { query_class.new(criteria) }
  Given do
    expect(criteria).to receive(:all).and_return(criteria)
    expect(criteria).to receive(:where).with(spends: 'a lot').and_return(criteria)
  end

  context 'does not chain :all' do
    Given(:query_class) { CustomersQuery }
    Given do
      expect(criteria).to receive(:all).and_return(criteria)
    end
    Then { !queryable.all.respond_to?(:queryable) }
  end

  context 'has a default query and default scope' do
    Given do
      expect(Customer).to receive(:all).and_return(criteria)
    end
    Then { CustomersQuery.new == criteria }
  end

  context 'using direct inclusion' do
    Given(:query_class) { CustomersQuery }

    describe 'chains mongoid criteria methods' do
      Given do
        expect(criteria).to receive(:where).with(prices: 'amazing').and_return(other_criteria)
      end
      Then { queryable.where(prices: 'amazing') == queryable }
      And  { queryable.queryable == other_criteria }
    end

    describe 'delegates mongoid aggregation methods' do
      Given do
        expect(criteria).to receive(:exists?).and_return(false)
      end
      Then { !queryable.exists? }
      And  { queryable.queryable == criteria }
    end
  end

  context 'using inheritance' do
    Given(:query_class) { ShopsQuery }

    describe 'chains mongoid criteria methods' do
      Given do
        expect(criteria).to receive(:includes).with(:shops, :accounts).and_return(other_criteria)
      end
      Then { queryable.includes(:shops, :accounts) == queryable }
      And  { queryable.queryable == other_criteria }
    end

    describe 'delegates mongoid aggregation methods' do
      Given do
        expect(criteria).to receive(:push).with('balance').and_return({ n: 250 })
      end
      Then { queryable.push('balance') == { n: 250 } }
      And  { queryable.queryable == criteria }
    end
  end
end
