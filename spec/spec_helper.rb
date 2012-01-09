# encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/spec')
$LOAD_PATH.unshift(File.dirname(__FILE__))

gem "minitest"
require "minitest/spec"
require "minitest/autorun"
require "minitest/matchers"
require "minitest/pride"
require "mocha"
require "pry"

require "skiima"

SKIIMA_ROOT = File.dirname(__FILE__)

Skiima.setup do |config|
  config.project_root = File.dirname(__FILE__)
  config.project_config_path = 'config'
  config.skiima_path = 'db/skiima'
  config.locale = :en
end