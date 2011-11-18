require File.expand_path('../../test_helper', __FILE__)

class TestSkiima < Skiima::Test
  def setup
    super
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