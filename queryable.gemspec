$LOAD_PATH.push File.expand_path('./lib', __dir__)
require 'queryable/version'

Gem::Specification.new do |s|
  s.name = 'queryable'
  s.version = Queryable::VERSION
  s.summary = 'Keep your scopes and queries flexible by using Ruby'
  s.description = 'Queryable is a module that encapsulates query building so you don\'t have to tuck scopes inside your models.'

  
  s.authors = ['Máximo Mussini']
  s.email = ['maximomussini@gmail.com']

  s.files = Dir.glob('{lib}/**/*.rb') + %w(README.md)
  s.license = 'MIT'
  s.homepage = 'https://github.com/ElMassimo/queryable'
  s.metadata = {
    'source_code_uri' => "https://github.com/ElMassimo/queryable/tree/main",
    'changelog_uri' => "https://github.com/ElMassimo/queryable/blob/main/CHANGELOG.md",
  }

  s.required_ruby_version = Gem::Requirement.new('>= 2.7')
end
