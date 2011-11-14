require File.expand_path('../../test_helper', __FILE__)

class TestLoaderConfig < Skiima::Test
  def setup
    @loader_config = Skiima::LoaderConfig.new(
      :locale => Skiima.locale_file,
      :config => Skiima.config_file,
      :depends => Skiima.depends_file)
  end

  def test_locale_is_set

  end

  def test_config_is_set

  end

  def test_dependencies_are_set

  end
end
