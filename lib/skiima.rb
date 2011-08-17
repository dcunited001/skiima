require "skiima/version"

module Skiima
  autoload :LoaderBase, 'skiima/loader_base'
  autoload :LoaderConfig, 'skiima/loader_config'
  autoload :Runner, 'skiima/runner'

  module DbAdapter
    autoload :Base, 'skiima/db_adapter/base'
    autoload :Mysql, 'skiima/db_adapter/mysql'
    autoload :Postgresql, 'skiima/db_adapter/postgresql'
    autoload :Sqlserver, 'skiima/db_adapter/sqlserver'
  end

  module SqlObject
    autoload :Base, 'skiima/sql_object/base'
    autoload :Table, 'skiima/sql_object/table'
    autoload :View, 'skiima/sql_object/view'
    autoload :Rule, 'skiima/sql_object/rule'
    autoload :Trigger, 'skiima/sql_object/trigger'
    autoload :Index, 'skiima/sql_object/index'
    autoload :Sp, 'skiima/sql_object/sp'
  end

  # Dynamically set inheritance in Ruby
  #http://stackoverflow.com/questions/3127069/how-to-dynamically-alter-inheritance-in-ruby

  #============================================================
  # Config locations
  #============================================================

  mattr_accessor :skiima_location
  @@skiima_location = 'db/skiima'

  mattr_accessor :skiima_config_location
  @@skiima_config_location = "#{skiima_location}skiima.yml"

  mattr_accessor :depends_config_location
  @@depends_config_location = "#{skiima_location}depends.yml"

  mattr_accessor :database_config_location
  @@database_config_location = 'config/database.yml'

  mattr_accessor :locale_location
  @@locale_location = 'config/locale'

  #============================================================
  # Config options
  #============================================================

  mattr_accessor :load_order
  @@load_order = :sequential

  mattr_accessor :locale
  @@locale = :en

  mattr_accessor :debug
  @@debug = false

  #============================================================
  # Supported Databases
  #============================================================

  mattr_accessor :supported_databases
  @@supported_databases = [:mysql, :postgresql, :sqlserver]

  #============================================================
  # Supported Database Objects
  #============================================================

  mattr_accessor :supported_objects
  @@supported_objects = {}  #loaded from skiima.yml

  def self.setup
    yield self
  end
end