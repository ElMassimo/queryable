Gem::Specification.new do |s|
  s.name = "queryable"
  s.version = '1.0.0'
  s.licenses = ['MIT']
  s.summary = "Keep your scopes and queries flexible by using Ruby"
  s.description = "Queryable is a module that encapsulates query building so you don't have to tuck scopes inside your models."
  s.authors = ["Máximo Mussini"]

  s.email = ["maximomussini@gmail.com"]
  s.extra_rdoc_files = ["README.md"]
  s.files = Dir.glob("{lib}/**/*.rb") + %w(README.md)
  s.homepage = %q{https://github.com/ElMassimo/queryable}

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.9.3'
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'activesupport'
end
