#you can use this hook to configure options for skiima module

Skiima.setup do |config|

  config.skiima_path = 'db/skiima'

  # ===> Configuration File Locations
  #   config.skiima_config_file = 'skiima.yml'
  #   config.depends_config_file = 'depends.yml'
  #   config.database_config_path = 'config/database.yml'
  #
  #   config.locale_path = 'config/locale'
  #   config.locale = :en

  # ===> Supported Databases and Objects
  #   (must implement custom adapters and db objects)
  #
  #   config.supported_databases = [:mysql, :postgresql, :sqlserver]
  #
  #   config.supported_objects = {
  #     :mysql => [:table, :view, :index, :function, :trigger],
  #     :postgresql => [:table, :view, :index, :function, :rule, :trigger],
  #     :sqlserver => [:table, :view, :index, :function, :sp, :trigger]
  #   }
end