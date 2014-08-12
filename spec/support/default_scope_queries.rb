require 'support/models'

class BaseQuery
  include Queryable
  include Queryable::DefaultScope
end

class PeopleQuery < BaseQuery

  default_scope :human
  scope :human, -> { where(human: true) }
end

class EmployeesQuery < PeopleQuery

  scope :worker, -> { where(work_hard: true) }
end

class LaidOffsQuery < EmployeesQuery

  default_scope :laid_off
  scope :laid_off, -> { where(laid_off: true) }
end

class AliensQuery < BaseQuery

  default_scope :not_human
  scope :not_human, -> { where(not_human: true) }
end
