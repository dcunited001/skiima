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
        config.skiima_path = 'config'
        config.database_config_path = 'config'

        # ===> Configuration File Locations
        #   config.skiima_config_file = 'skiima.yml'
        #   config.depends_config_file = 'depends.yml'
        #   config.database_config_path = 'config/database.yml'
        #
        #   config.locale_path = 'config/locale'
        #   config.locale = :en
      end
    end

    #tests that the config paths are correct (and the files can be loaded?)
    def test_path_accessors
      current_path = File.dirname(__FILE__)
      skiima_config = File.join(current_path, 'config')
      skiima_yml_file = File.join(skiima_config, 'skiima.yml')

      db_config = File.join(current_path, 'config')
      db_config_file = File.join(db_config, 'database.yml')

      assert_equal(Skiima.project_root, current_path)
      assert_equal(Skiima.skiima_path, skiima_config)
      assert_equal(Skiima.database_config_path, db_config)
      assert_equal(Skiima.database_config_file, db_config_file)
    end

  end
end
