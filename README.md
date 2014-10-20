Queryable
=====================
[![Gem Version](https://badge.fury.io/rb/queryable.svg)](http://badge.fury.io/rb/queryable)
[![Build Status](https://travis-ci.org/ElMassimo/queryable.svg)](https://travis-ci.org/ElMassimo/queryable)
[![Test Coverage](https://codeclimate.com/github/ElMassimo/queryable/badges/coverage.svg)](https://codeclimate.com/github/ElMassimo/queryable)
[![Code Climate](https://codeclimate.com/github/ElMassimo/queryable.png)](https://codeclimate.com/github/ElMassimo/queryable)
[![Inline docs](http://inch-ci.org/github/ElMassimo/queryable.svg)](http://inch-ci.org/github/ElMassimo/queryable)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/ElMassimo/queryable/blob/master/LICENSE.txt)
<!-- [![Coverage Status](https://coveralls.io/repos/ElMassimo/queryable/badge.png)](https://coveralls.io/r/ElMassimo/queryable) -->

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
def CustomersQuery
  delegate :update_all, :destroy_all
end
```

## Advantages

* Query objects are easy to understand.
* You can inherit, mixin, and chain queries in a very natural way.
* Increased testability, pretty close to being ORM/ODM agnostic.

## Optional Modules
There are three opt-in modules that can help you when creating query objects.
These modules would need to be manually required during app initialization or
wherever necessary (in Rails, config/initializers).

### DefaultQuery
Provides default initialization for query objects, by attempting to infer the
class name of the default collection for the query, and it also provides a
`queryable` method to specify it.

```ruby
require 'queryable/default_query'

def CustomersQuery
  include Queryable
  include Queryable::DefaultQuery
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

### Chainable

While scopes are great because of their terseness, they can be limiting because
the block executes in the context of the internal query, so methods, constants,
and variables of the Queryable are not accessible.

For those cases, you can use a normal method, and then `chain` it. Chainable
will take care of setting the return value of the method as the internal query,
and return `self` at the end to make the method chainable.

```ruby
class CustomersQuery
  include Queryable
  include Queryable::Chainable

  chain :active, :recent

  def active
    where(status: 'active')
  end

  def recent
    queryable.desc(:logged_in_at)
  end

  chain def search(field_values)
    field_values.inject(queryable) { |query, (field, value)|
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
require 'queryable/chainable'
require 'queryable/default_scope'
require 'queryable/default_query'

def BaseQuery
  include Queryable
  include Queryable::Chainable
  include Queryable::DefaultScope
  include Queryable::DefaultQuery

  # If you want to be concise:
  include Queryable::DefaultQuery, Queryable::DefaultScope, Queryable::Chainable, Queryable

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

## RDocs

You can view the **Queryable** documentation in RDoc format here:

http://rubydoc.info/github/ElMassimo/queryable/master/frames


License
--------

    Copyright (c) 2014 Máximo Mussini

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
