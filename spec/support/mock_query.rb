class MockQuery < Hash
  attr_reader :mocked_scopes, :items

  def initialize(scopes=nil)
    @mocked_scopes = scopes || []
    super()
  end

  def scoped?
    any?
  end

  def scoped_by?(scope, *args)
    fetch(scope, []).include?(args)
  end

  def all
    self
  end

  private

  def mocks_scope?(scope)
    mocked_scopes.include?(scope)
  end

  def record_invocation(scope, *args)
    clone.tap do |clone|
      clone[scope] = fetch(scope, []).push(args)
    end
  end

  def method_missing(scope, *args)
    mocks_scope?(scope) ? record_invocation(scope, *args) : super
  end
end
