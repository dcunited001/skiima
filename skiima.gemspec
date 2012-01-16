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

  # i've tried to remove this dependancy,
  #   but i rely too much on camelize and esp singularize
  s.add_dependency "active_support", '~> 3'
  s.add_dependency "fast_gettext", '~> 0.6.0'

  s.add_development_dependency "bundler", '>= 1.0.21'
  s.add_development_dependency "minitest", '~> 2.9.1'
  s.add_development_dependency "minitest-matchers", '~> 1.1.3'
  s.add_development_dependency "mocha", '~> 0.10.0'
end

# configuration interface
# TODO: replace Skiima.project_path, project_config_path, config_file with {base_path}

# logging
# TODO: replace Skiima.puts
# TODO: redirect logging to file
# TODO: redirect logging to $errout

# active support dependencies:
# TODO: replace mattr_accessor
# TODO: camelize (avoid namespace clash)
# TODO: underscore (avoid namespace clash)

# active record dependencies:
# TODO: replace(avoid) execute_sql (replace with libraries?)
# TODO: conditionally load sql dependencies

# dependencies
# TODO: parse tablenames dependencies hash
# TODO: create a list of class names from dependencies hash

# thor tasks
# TODO: thor task to load all sets
# TODO: thor task to load specific sets
# TODO: delegate rake tasks to thor (how?)


