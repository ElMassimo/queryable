## [4.0.0](https://github.com/ElMassimo/queryable/compare/4.0.0...3.0.2) (2022-02-24)

### BREAKING CHANGES

- Minimum Ruby Version: 2.7

  Using the `...` delegation syntax for consistency and simplicity.

- Immutability of query objects

  No longer mutating the internal query in place. This was a common cause of
  bugs and was not consistent with the behavior of the underlying queries.

  Now, every time a method is chained a new query object is returned.

- Default Scopes are no longer supported

  Default scopes are an anti-pattern. It's preferable to be explicit and use the
  builder pattern to create a new query object with the desired scopes.

- Chainable was removed

  Originally, common methods in Mongoid and ActiveRecord queries were not being
  chained, as a way to force all scopes to be defined explicitly in query objects.

  This proved to be cumbersome in practice, and after making all methods that
  extend a query chainable, there simply was no reason to use `chain` anymore.
