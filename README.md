Queryable
=====================
[![Gem Version](https://badge.fury.io/rb/queryable.svg)](http://badge.fury.io/rb/queryable)
[![Build Status](https://travis-ci.org/ElMassimo/queryable.svg)](https://travis-ci.org/ElMassimo/queryable)
[![Code Climate](https://codeclimate.com/github/ElMassimo/queryable.png)](https://codeclimate.com/github/ElMassimo/queryable)
[![Inline docs](http://inch-ci.org/github/ElMassimo/queryable.svg)](http://inch-ci.org/github/ElMassimo/queryable)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/ElMassimo/queryable/blob/master/LICENSE.txt)
<!-- [![Coverage Status](https://coveralls.io/repos/ElMassimo/queryable/badge.png)](https://coveralls.io/r/ElMassimo/queryable) -->

Queryable is a mixin that allows you to easily define query objects with chainable scopes.

### Scopes

Scopes serve to encapsulate reusable business rules, a method is defined with
the selected name and block (or proc)

### Scopeable Methods

While scopes are great because of their terseness, they can be limiting because
the block executes in the context of the internal query, so methods, constants,
and variables of the Queryable are not accessible.

For those cases, you can use a normal method, and then `scope` it. Queryable
will take care of setting the return value of the method as the internal query,
and return `self` at the end to make the method chainable.

### Delegation

By default most Array methods are delegated to the internal query. It's possible
to delegate extra methods to the query by calling `delegate`.
```ruby
def CustomersQuery
  delegate :update_all, :destroy_all
end
```

## Usage
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

  scope def search(field_values)
    field_values.inject(customers) { |customers, (field, value)|
      customers.where(field => /#{value}/i)
    }
  end

  def search_in_current(field_values)
    search(field_values).current
  end

  scope :search_in_current
end


CustomerQuery.new(shop.customers).miller_fans.search_in_current(last_name: 'M')
```

## Optional Modules
Besides Queryable, there are two opt-in modules that can help you when creating
query objects. These modules would need to be manually required during app
initialization or wherever necessary (in Rails, config/initializers).

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

CustomersQuery.new.query == Customer.all
OldCustomersQuery.new.query == ArchivedCustomers.all
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

CustomersQuery.new.query == Customer.where(:last_purchase.gt => 7.days.ago)

BigCustomersQuery.new.query ==
Customer.where(:last_purchase.gt => 7.days.ago, :total_expense.gt => 9999999)
```

### Notes
To avoid repetition, it's a good idea to create a `BaseQuery` object
to contain both the modules inclusion, and common scopes you may reuse.

```ruby
require 'queryable/default_query'
require 'queryable/default_scope'

def BaseQuery
  include Queryable
  include Queryable::DefaultScope
  include Queryable::DefaultQuery
  
  scope :recent, ->{ where(:created_at.gt => 1.week.ago) }
end

def CustomersQuery < BaseQuery
...
end
```

## Advantages

* Query objects are easy to understand.
* You can inherit, mixin, and chain queries in a very natural way.
* Increased testability, pretty close to being ORM/ODM agnostic.

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
