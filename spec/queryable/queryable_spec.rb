require 'spec_helper'
require './lib/queryable'
require 'support/queries'

describe Queryable do

  Given(:query) { MockQuery.new([*allows]) }

  context 'when returning a different query object' do
    # owners => OwnerQuery.new.owners_of(self)
    # scope :owners_of, ->(shops) {self.in(_id: shops.distinct(:owner_id)) }
    Given do
      allow(Owner).to receive(:all).and_return(owner_query)
      expect(queryable).to receive(:distinct).with(:owner_id).and_return(:YEAHHH)
    end
    Given(:allows) { :distinct }
    Given(:queryable) { ShopQuery.new(query) }
    Given(:owner_query) { MockQuery.new([:in]) }
    When (:result) { queryable.owners }
    Then { result.is_a? OwnerQuery }
    And  { result.query.scoped_by?(:in, _id: :YEAHHH) }
    And  { OwnerQuery.new == owner_query }
  end

  context 'when using common array methods' do
    Given(:funky_array) { [:so, :groovy, :man, :so] }
    Given(:queryable) { ShopQuery.new(funky_array) }
    Given { allow(funky_array).to receive(:all).and_return(funky_array) }

    Then { queryable == [:so, :groovy, :man, :so] }

    When(:each) { queryable.each.to_a }
    Then { each == [:so, :groovy, :man, :so ] }

    When(:map) { queryable.map(&:to_s) }
    Then { map == ['so', 'groovy', 'man', 'so'] }

    When(:uniq) { queryable.uniq }
    Then { uniq == [:so, :groovy, :man] }
  end

  context 'when using delegating and chaining' do
    Given(:criteria) { double('criteria') }
    Given(:other_criteria) { double('criteria') }
    Given(:queryable) { CustomerQuery.new(criteria) }

    Given do
      allow(criteria).to receive(:all).and_return(criteria)
      expect(criteria).to receive(:awesome).with(:sandwiches, :bro).and_return(other_criteria)
      expect(other_criteria).to receive(:great).with(:beer).and_return(criteria)
      expect(criteria).to receive(:cool).and_return(other_criteria)
    end

    Then { queryable.awesome(:sandwiches, :bro) == queryable }
    And  { queryable.great(:beer) == queryable }
    And  { queryable.cool == queryable }
  end
end
