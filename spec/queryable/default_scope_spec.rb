require 'spec_helper'
require './lib/queryable'
require './lib/queryable/default_scope'
require 'support/default_scope_queries'

describe Queryable do

  Given(:initial_query) { MockQuery.new([:where]) }
  When(:query) { query_class.new(initial_query).query }

  context 'when not scoping' do
    Given(:query_class) { BaseQuery }
    Then { query.keys == [] }
  end

  context 'when first scope' do
    Given(:query_class) { PeopleQuery }
    Then { query[:where] == [[{ human: true }]] }
    And  { query.keys == [:where] }
  end

  context 'when subclass of default scoped queryable' do
    Given(:query_class) { EmployeesQuery }
    Then { query[:where] == [[{ human: true }]] }
    And  { query.keys == [:where] }
  end

  context 'when subclass of default scoped queryable with default scope' do
    Given(:query_class) { LaidOffsQuery }
    Then { query[:where] == [[{ human: true }], [{ laid_off: true }]] }
    And  { query.keys == [:where] }
  end

  context 'when separate class' do
    Given(:query_class) { AliensQuery }
    Then { query[:where] == [[{ not_human: true }]] }
    And  { query.keys == [:where] }
  end
end
