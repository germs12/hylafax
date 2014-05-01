# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hylafax/version'

Gem::Specification.new do |gem|
  gem.name          = "hylafax"
  gem.version       = Hylafax::VERSION
  gem.authors       = ["James Thullbery"]
  gem.email         = ["ifndef@gmail.com"]
  gem.description   = %q{Ruby wrapper for Hylafax Server}
  gem.summary       = %q{Ruby wrapper for Hylafax Server}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_development_dependency 'rspec', '~>2.12.0'
  gem.add_development_dependency 'pry'
end