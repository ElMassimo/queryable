require 'spec_helper'
require './lib/queryable'
require 'support/queries'

describe 'Queryable::define_query' do
  Given(:query) { MockQuery.new([*allows]) }
  Given(:queryable) { OwnerQuery.new(query) }

  context 'when accessing a method of the Queryable object' do
    # greedy => define_query {|query| query.with_size(many) }
    Given(:allows) { :with_size }
    When (:result) { queryable.greedy }
    Then { result.is_a? OwnerQuery }
    And  { result.query.scoped_by?(:with_size, shops: 10) }
  end

  context 'when last chained method is a method of the query' do
    # successful => define_query { success_over(9000).order(:name) }
    Given(:allows) { [:gt, :order] }
    When (:result) { queryable.successful }
    Then { result.is_a? OwnerQuery }
    And  { result.query.scoped_by?(:gt, success: 9000) }
    And  { result.query.scoped_by?(:order, :name) }
  end

  context 'when the method uses the provided query and a parameter' do
    Given(:allows) { [:where] }
    When (:result) { queryable.search(name: :Jack, surname: :Daniels) }
    Then { result.is_a? OwnerQuery }
    And  { result.query.scoped_by?(:where, name: /Jack/i) }
    And  { result.query.scoped_by?(:where, surname: /Daniels/i) }
  end

  context 'when combining several queries' do
    Given(:allows) { [:gt, :order, :with_size] }
    When (:result) { queryable.greedy.successful }
    Then { result.is_a? OwnerQuery }
    And  { result.query.scoped_by?(:with_size, shops: 10) }
    And  { result.query.scoped_by?(:gt, success: 9000) }
    And  { result.query.scoped_by?(:order, :name) }
  end
end
