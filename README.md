Queryable
=====================
[![Gem Version](https://badge.fury.io/rb/queryable.svg)](http://badge.fury.io/rb/queryable)
[![Build Status](https://travis-ci.org/ElMassimo/queryable.svg)](https://travis-ci.org/ElMassimo/queryable)
[![Test Coverage](https://codeclimate.com/github/ElMassimo/queryable/badges/coverage.svg)](https://codeclimate.com/github/ElMassimo/queryable)
[![Code Climate](https://codeclimate.com/github/ElMassimo/queryable.svg)](https://codeclimate.com/github/ElMassimo/queryable)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/ElMassimo/queryable/blob/master/LICENSE.txt)

Queryable is a mixin that allows you to easily define query objects with chainable scopes.

### Scopes

Scopes serve to encapsulate reusable business rules, a method is defined with
the selected name and block (or proc)
```ruby
class CustomersQuery
  include Queryable

  scope(:recent) { desc(:logged_in_at) }

  scope :active, ->{ where(status: 'active') }

  scope :favourite_brand do |product, brand|
    where("favourites.#{product}": brand)
  end

  def current
    recent.active
  end

  def miller_fans
    favourite_brand(:beer, :Miller)
  end
end


CustomerQuery.new(shop.customers).miller_fans
```

### Delegation

By default most Array methods are delegated to the internal query. It's possible
to delegate extra methods to the query by calling `delegate`.
```ruby
class CustomersQuery
  include Queryable

  delegate :update_all, :destroy_all, :exists?
end
```

### Delegate and Chain

Sometimes you want to delegate a method to the internal query, but continue
working with the query object like if you were calling scopes.

You can achieve that using `delegate_and_chain`, which will delegate the method
call, assign the return value as the internal query, and return the query object.

```ruby
class CustomersQuery
  include Queryable

  delegate_and_chain :where, :order_by
end
```

## Advantages

* Query objects are easy to understand.
* You can inherit, mixin, and chain queries in a very natural way.
* Increased testability, pretty close to being ORM/ODM agnostic.

## Basic Usage

If you are using Mongoid or ActiveRecord, you might want to try the
`Queryable::Mongoid` and `Queryable::ActiveRecord` modules that already take
care of delegating and chaining most of the methods in the underlying queries.

```ruby
class CustomersQuery
  include Queryable::Mongoid
end

CustomersQuery.new.where(:amount_purchased.gt => 2).active.asc(:logged_in_at)
```

This modules also include all the optional modules. If you would like to opt-out
of the other modules you can follow the approach in the [Notes](https://github.com/ElMassimo/queryable#notes) section.

## Advanced Usage
There are three opt-in modules that can help you when creating query objects.
These modules would need to be manually required during app initialization or
wherever necessary (in Rails, config/initializers).

### Query Initialization 

Provides default initialization for query objects, by attempting to infer the
class name of the default collection for the query, and it also provides a
`queryable` method to specify it.

```ruby
require 'queryable'

def CustomersQuery
  include Queryable
end

def OldCustomersQuery < CustomersQuery
  queryable ArchivedCustomers
end

CustomersQuery.new.queryable == Customer.all
OldCustomersQuery.new.queryable == ArchivedCustomers.all
```
If you want to use common base objects for your queries, you may want want to
delay the automatic inference:

```ruby
class BaseQuery
  include Queryable
  include Queryable::DefaultQuery

  queryable false
end

class CustomersQuery < BaseQuery
end

CustomersQuery.new.queryable == Customer.all
```

### DefaultScope
Allows to define default scopes in query objects, and inherit them in query
object subclasses.

```ruby
require 'queryable/default_scope'

def CustomersQuery
  include Queryable
  include Queryable::DefaultScope
  include Queryable::DefaultQuery

  default_scope :active
  scope :active, -> { where(:last_purchase.gt => 7.days.ago) }
end

def BigCustomersQuery < CustomersQuery
  default_scope :big_spender
  scope :big_spender, -> { where(:total_expense.gt => 9999999) }
end

CustomersQuery.new.queryable == Customer.where(:last_purchase.gt => 7.days.ago)

BigCustomersQuery.new.queryable ==
Customer.where(:last_purchase.gt => 7.days.ago, :total_expense.gt => 9999999)
```

### Composition

While scopes are great because of their terseness, they can be limiting because
the block executes in the context of the internal query, so methods, constants,
and variables of the Queryable are not accessible.

For those cases, it's preferable to use normal methods instead.

```ruby
class CustomersQuery < BaseQuery
  def active
    where(status: 'active')
  end

  def recent
    desc(:logged_in_at)
  end

  def search(field_values)
    field_values.inject(self) { |query, (field, value)|
      query.where(field => /#{value}/i)
    }
  end

  def search_in_active(field_values)
    search(field_values).active
  end
end


CustomerQuery.new(shop.customers).miller_fans.search_in_current(last_name: 'M')
```

### Notes

To avoid repetition, it's a good idea to create a `BaseQuery` object
to contain both the modules inclusion, and common scopes you may reuse.

```ruby

def BaseQuery
  include Queryable::ActiveRecord

  queryable false

  scope :recent, ->{ where(:created_at.gt => 1.week.ago) }
end

def CustomersQuery < BaseQuery
...
end
```

## Testing

You can check the [specs](https://github.com/ElMassimo/queryable/tree/master/spec) of the project
to check how to test query objects without even having to require the ORM/ODM, or
you can test by requiring your ORM/ODM and executing queries as usual.
