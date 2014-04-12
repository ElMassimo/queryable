Queryable
=====================
[![Gem Version](https://badge.fury.io/rb/queryable.svg)](http://badge.fury.io/rb/queryable)
[![Build Status](https://travis-ci.org/ElMassimo/queryable.svg)](https://travis-ci.org/ElMassimo/queryable)
[![Coverage Status](https://coveralls.io/repos/ElMassimo/queryable/badge.png)](https://coveralls.io/r/ElMassimo/queryable)
<!-- [![Code Climate](https://codeclimate.com/github/ElMassimo/queryable.png)](https://codeclimate.com/github/ElMassimo/queryable) -->

Queryable is a mixin that allows you to easily define query objects with chainable scopes.

## Usage
```ruby
class CustomerQuery
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

  def search_in_current(field_values)
    define_query do |customers|
      field_values.inject(customers) { |customers, (field, value)|
        customers.where(field => /#{value}/i)
      }
    end.current
  end
end


CustomerQuery.new(shop.customers).miller_fans.search_in_current(last_name: 'M')
```

### Scopes

Scopes serve to encapsulate reusable business rules, a method is defined with
the selected name and block (or proc)

### Define Query

While scopes are great because of their terseness, they can be limiting because
the block executes in the context of the internal query, so methods, constants,
and variables of the Queryable are not accessible.

For those cases, you can use `define_query`, which is a convenience setter for
the internal query, that also takes care of returning `self` at the end of the
call to make the methods chainable.

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
