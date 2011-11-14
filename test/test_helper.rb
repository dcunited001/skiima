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

    #tests that the config paths are correct (and the files can be loaded?)
    def test_path_accessors
      #expected config paths
      current_path = File.dirname(__FILE__)
      project_config_path = File.join(current_path, 'config')
      skiima_yml_file = File.join(project_config_path, 'skiima.yml')
      db_config_file = File.join(project_config_path, 'database.yml')

      #expected depends config paths
      skiima_path = File.join(current_path, 'db/skiima')
      depends_file = File.join(skiima_path, 'depends.yml')

      #expected locale config paths
      locale_path = File.join(current_path, 'config')
      locale_file = File.join(locale_path, 'skiima.en.yml')

      assert_equal(Skiima.project_root, current_path)
      assert_equal(Skiima.project_config_path, project_config_path)
      assert_equal(Skiima.config_file, skiima_yml_file)
      assert_equal(Skiima.database_config_file, db_config_file)

      assert_equal(Skiima.skiima_path, skiima_path)
      assert_equal(Skiima.depends_file, depends_file)

      assert_equal(Skiima.locale_path, locale_path)
      assert_equal(Skiima.locale_file, locale_file)
    end

  end
end

