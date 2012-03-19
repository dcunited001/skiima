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
  s.add_dependency "fast_gettext", '~> 0.6.0'
  s.add_dependency "erubis", '~> 2.7.0'

  s.add_development_dependency "bundler", '>= 1.0.21'
  s.add_development_dependency "minitest", '~> 2.9.1'
  s.add_development_dependency "minitest-matchers", '~> 1.1.3'
  s.add_development_dependency "mocha", '~> 0.10.0'
end

# configuration interface
# TODO: replace Skiima.project_path, project_config_path, config_file with {base_path}

# logging
# TODO: add logger messages

# active support dependencies:
# TODO: camelize (avoid namespace clash)
# TODO: underscore (avoid namespace clash)

# active record dependencies:
# TODO: conditionally load sql dependencies
# TODO: create loader class or loader method (See ActiveRecord::Base::ConnectionSpecification::Resolver)
# TODO: implement Postgresql adapter
# TODO: find best place for 

# sql objects:
# change sql file formatting to include versioning
# how to obtain database version over connection?
# whats the best way to manage different formats for different providers
# a means of stating which objects are supported for each provider.
# a means of extending the supported objects for each provider.
# a means of changing formats per version of database

# dependencies
# TODO: create a list of class names from dependencies hash
# TODO: create base sql objects from depends.yml, without knowing if they are valid
# TODO: get sql objects class to change itself into the appropriate subclass, post facto
# TODO: change depends.yml structure to allow for separate dependency structures per adapter
# TODO: change depends.yml structure to accommodate multiple sql provider versions

# thor tasks
# TODO: thor task to load all sets
# TODO: thor task to load specific sets
# TODO: delegate rake tasks to thor (how?)
