require 'spec_helper'
require './lib/queryable'
require 'support/queries'

describe 'Queryable::scope' do
  Given(:query) { MockQuery.new([*allows]) }

  context 'when using a proc without parameters' do
    # scope :open, -> { where(open: true) }
    Given(:queryable) { ShopQuery.new(query) }
    Given(:allows) { :where }
    When (:result) { queryable.open }
    Then { result.is_a? ShopQuery }
    And  { result.query.scoped_by?(:where, open: true) }
  end

  context 'when using a proc with parameters' do
    # scope :located_at, ->(place) { where(location: place) }
    Given(:queryable) { ShopQuery.new(query) }
    Given(:allows) { :where }
    When (:result) { queryable.located_at(:somewhere) }
    Then { result.is_a? ShopQuery }
    And  { result.query.scoped_by?(:where, location: :somewhere) }
  end

  context 'when using a block without parameters' do
    # scope :order_by_name, -> { asc(:name) }
    Given(:queryable) { ShopQuery.new(query) }
    Given(:allows) { :asc }
    When (:result) { queryable.order_by_name }
    Then { result.is_a? ShopQuery }
    And  { result.query.scoped_by?(:asc, :name) }
  end

  context 'when using a block with parameters' do
    # scope(:shopped_after) {|date| gt(shopped_at: date) }
    Given(:queryable) { CustomerQuery.new(query) }
    Given(:allows) { :gt }
    When (:result) { queryable.shopped_after(Date.today) }
    Then { result.is_a? CustomerQuery }
    And  { result.query.scoped_by?(:gt, shopped_at: Date.today) }
  end

  context 'when combining several queries I' do
    Given(:queryable) { ShopQuery.new(query) }
    Given(:allows) { [:asc, :where] }
    When (:result) { queryable.open.located_at(:somewhere).order_by_name }
    Then { result.is_a? ShopQuery }
    And  { result.query.scoped_by?(:where, open: true) }
    And  { result.query.scoped_by?(:where, location: :somewhere) }
    And  { result.query.scoped_by?(:asc, :name) }
  end

  context 'when combining several queries II' do
    # order_by_expense.recent.shopped_after(date)
    Given(:queryable) { CustomerQuery.new(query) }
    Given(:allows) { [:desc, :gt] }
    When (:result) { queryable.big_expenders_after(Date.today) }
    Then { result.is_a? CustomerQuery }
    And  { result.query.scoped_by?(:desc, :expense_amount) }
    And  { result.query.scoped_by?(:desc, :shopped_at) }
    And  { result.query.scoped_by?(:gt, shopped_at: Date.today) }
  end
end
