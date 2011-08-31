SkiimaApp::Application.configure do
  Skiima.setup do |config|
    config.project_root = Rails.root
    config.skiima_path = 'db/skiima'

    # ===> Configuration File Locations
    #   config.skiima_config_file = 'skiima.yml'
    #   config.depends_config_file = 'depends.yml'
    #   config.database_config_path = 'config/database.yml'
    #   config.locale_path = 'config/locale'

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

  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false
end
