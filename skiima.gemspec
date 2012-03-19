# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "skiima/version"

Gem::Specification.new do |s|
  s.name        = "skiima"
  s.version     = Skiima::VERSION
  s.authors     = ["David Conner"]
  s.email       = ["dconner.pro@gmail.com"]
  s.homepage    = "http://github.com/dcunited001/skiima"
  s.summary     = %q{A SQL object manager for Rails projects}
  s.description = %q{Skiima helps to manage SQL objects like views and functions}

  s.rubyforge_project = "skiima"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "fast_gettext", '~> 0.6.0'
  s.add_dependency "erubis", '~> 2.7.0'

  s.add_development_dependency "bundler", '>= 1.0.21'
  s.add_development_dependency "minitest", '~> 2.9.1'
  s.add_development_dependency "minitest-matchers", '~> 1.1.3'
  s.add_development_dependency "mocha", '~> 0.10.0'
end

# Logging
# TODO: add logging messages
# TODO: convert to i18n messages

# Mysql Adapter
# TODO: add base mysql adapter
# TODO: add mysql adapter
# TODO: add mysql2 adapter

# Refactor:
# 

# Thor tasks
# TODO: thor task to load all sets
# TODO: thor task to load specific sets
# TODO: delegate rake tasks to thor (how?)
