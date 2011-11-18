require 'minitest/autorun'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'skiima'

module Skiima
  class Test < MiniTest::Spec
    def setup
      super
      Skiima.setup do |config|
        config.project_root = File.dirname(__FILE__)
        config.project_config_path = 'config'
        config.skiima_path = 'db/skiima'
        config.locale_path = 'config'
        config.locale = :en
      end
    end
  end
end

