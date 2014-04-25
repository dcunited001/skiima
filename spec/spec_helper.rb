# encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/spec')
$LOAD_PATH.unshift(File.dirname(__FILE__))

gem "minitest"
require "minitest/spec"
require "minitest/autorun"
require "minitest/matchers"
require "minitest/pride"
require "mocha/setup"
require "pry"

# To Test:
# TODO: finish skiima_spec.rb
# TODO: finish loader_spec.rb
# TODO: finish struct_spec.rb
# TODO: finish config_spec.rb
# TODO: finish resolver_spec.rb

# Integration:
# TODO: update mysql_spec.rb
# TODO: update mysql2_spec.rb
# TODO: update postgresql_spec.rb

Bundler.require(:active_record)

require "skiima"

SKIIMA_ROOT = File.expand_path('./spec')

Skiima.setup do |config|
  config.root_path = SKIIMA_ROOT
  config.config_path = 'config'
  config.scripts_path = 'db/skiima'
  config.locale = :en
end

def ensure_closed(s, &block)
  yield s
ensure
  s.connector.disconnect!
end

def within_transaction(s, &block)
  s.connector.begin_db_transaction
  yield s
ensure
  s.connector.rollback_db_transaction
end

# minitest config for shared examples
MiniTest::Spec.class_eval do
  def self.shared_examples
    @shared_examples ||= {}
  end
end

module MiniTest::Spec::SharedExamples
  def shared_examples_for(desc, &block)
    MiniTest::Spec.shared_examples[desc] = block
  end

  def it_behaves_like(desc)
    self.instance_eval(&MiniTest::Spec.shared_examples[desc])
  end
end

Object.class_eval { include(MiniTest::Spec::SharedExamples) }
require 'shared_examples/config_shared_example'