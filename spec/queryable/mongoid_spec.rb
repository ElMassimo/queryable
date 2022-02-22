require 'spec_helper'
require './lib/queryable/mongoid'
require 'support/mongoid_queries'

describe Queryable::Mongoid do

  Given(:criteria) { double('criteria') }
  Given(:other_criteria) { double('criteria') }
  When(:query_object) { query_class.new(criteria) }

  context 'does not chain :queryable' do
    Given(:query_class) { CustomersQuery }
    Then { query_object.queryable == criteria }
    And { !query_object.queryable.respond_to?(:queryable) }
  end

  context 'has a default query and default scope' do
    Given do
      expect(Customer).to receive(:all).and_return(criteria)
    end
    Then { CustomersQuery.new == criteria }
  end

  context 'using direct inclusion' do
    Given(:query_class) { CustomersQuery }

    describe 'chains methods on self' do
      Given do
        expect(criteria).to receive(:where).with(spends: 'a lot').and_return(other_criteria)
      end
      When(:new_query_object) { query_object.big_spender }
      Then { new_query_object != query_object }
      And  { new_query_object.queryable == other_criteria }
    end

    describe 'chains mongoid criteria methods' do
      Given do
        expect(criteria).to receive(:where).with(prices: 'amazing').and_return(other_criteria)
      end
      When(:new_query_object) { query_object.where(prices: 'amazing') }
      Then { new_query_object != query_object }
      And  { new_query_object.queryable == other_criteria }
    end

    describe 'delegates mongoid aggregation methods' do
      Given do
        expect(criteria).to receive(:exists?).and_return(false)
      end
      Then { !query_object.exists? }
      And  { query_object.queryable == criteria }
    end
  end

  context 'using inheritance' do
    Given(:query_class) { ShopsQuery }

    describe 'chains methods on self' do
      Given do
        expect(criteria).to receive(:where).with(spends: 'a lot').and_return(other_criteria)
      end
      When(:new_query_object) { query_object.big_spender }
      Then { new_query_object != query_object }
      And  { new_query_object.queryable == other_criteria }
    end

    describe 'chains mongoid criteria methods' do
      Given do
        expect(criteria).to receive(:includes).with(:shops, :accounts).and_return(other_criteria)
      end
      When(:new_query_object) { query_object.includes(:shops, :accounts) }
      Then { new_query_object != query_object }
      And  { new_query_object.queryable == other_criteria }
    end

    describe 'delegates mongoid aggregation methods' do
      Given do
        expect(criteria).to receive(:push).with('balance').and_return({ n: 250 })
      end
      When(:result) { query_object.push('balance') }
      Then { result == { n: 250 } }
      And { query_object.queryable == criteria }
    end
  end
end
