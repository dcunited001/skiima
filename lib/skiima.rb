require "skiima/version"

module Skiima
  require 'skiima/loader_config'
  require 'skiima/runner'

  #there's got to be a better way to load these files
  autoload :DbAdapter, 'skiima/db_adapter/base'
  require 'skiima/db_adapter/mysql'
  require 'skiima/db_adapter/postgresql'
  require 'skiima/db_adapter/sqlserver'

  autoload :Loader, 'skiima/loader/base'
  # require 'blah'  # no implementations yet

  autoload :SqlObject, 'skiima/sql_object/base'
  require 'skiima/sql_object/table'
  require 'skiima/sql_object/index'
  require 'skiima/sql_object/view'
  require 'skiima/sql_object/function'
  require 'skiima/sql_object/sp'
  require 'skiima/sql_object/rule'
  require 'skiima/sql_object/trigger'

  autoload :Dependency, 'skiima/dependency/reader'
  require 'skiima/dependency/sequential'
  require 'skiima/dependency/tree'

  #not sure why this didn't work.
  #Dir[File.join('skiima', 'db_adapter', '**')].each { |rb| require rb if rb != 'base.rb'}
  #Dir[File.join('skiima', 'loader', '**')].each { |rb| require rb if rb != 'base.rb' }
  #Dir[File.join('skiima', 'sql_object', '**')].each { |rb| require rb if rb != 'base.rb' }

  # This syntax looks alot cooler, but classes are set up wrong
  #
  #autoload :LoaderConfig, 'skiima/loader_config'
  #autoload :Runner, 'skiima/runner'
  #
  #module Loader
  #  autoload :Base, 'skiima/loader/base'
  #end
  #
  #module DbAdapter
  #  autoload :Base, 'skiima/db_adapter/base'
  #  autoload :Mysql, 'skiima/db_adapter/mysql'
  #  autoload :Postgresql, 'skiima/db_adapter/postgresql'
  #  autoload :Sqlserver, 'skiima/db_adapter/sqlserver'
  #end
  #
  #module SqlObject
  #  autoload :Base, 'skiima/sql_object/base'
  #  autoload :Table, 'skiima/sql_object/table'
  #  autoload :View, 'skiima/sql_object/view'
  #  autoload :Rule, 'skiima/sql_object/rule'
  #  autoload :Trigger, 'skiima/sql_object/trigger'
  #  autoload :Index, 'skiima/sql_object/index'
  #  autoload :Sp, 'skiima/sql_object/sp'
  #end

  # Dynamically set inheritance in Ruby
  #http://stackoverflow.com/questions/3127069/how-to-dynamically-alter-inheritance-in-ruby

  #============================================================
  # Config locations
  #============================================================
  mattr_accessor :project_root; @@project_root = 'specify/in/config/block'  #must be overridden (need a better way to do this)
  mattr_accessor :skiima_path; @@skiima_path = 'db/skiima'
  mattr_accessor :skiima_config_file; @@skiima_config_file = 'skiima.yml'
  mattr_accessor :depends_config_file; @@depends_config_file = 'depends.yml'
  mattr_accessor :database_config_path; @@database_config_file = 'config/database.yml'
  mattr_accessor :locale_path; @@locale_path = 'config/locales'

  #============================================================
  # Config options
  #============================================================
  #not sure of the best way to abstract this for Multiple ORM's
  #   or whether there's even a need for that
  #mattr_accessor :orm, :active_record

  mattr_accessor :load_order; @@load_order = :sequential
  mattr_accessor :locale; @@locale = :en
  mattr_accessor :debug; @@debug = false

  #============================================================
  # Supported Databases & Objects
  #     (can be overridden in config block)
  #============================================================

  mattr_accessor :supported_databases
  @@supported_databases = [:mysql, :postgresql, :sqlserver]

  mattr_accessor :supported_objects
  @@supported_objects = {
    :mysql => [:table, :view, :index, :function, :trigger],
    :postgresql => [:table, :view, :index, :function, :rule, :trigger],
    :sqlserver => [:table, :view, :index, :function, :sp, :trigger]
  }

  mattr_accessor :supported_dependency_readers
  @@supported_dependency_readers = [:sequential, :tree]

  def self.setup
    yield self
  end

  #============================================================
  # Active Record Models
  #============================================================
  #mattr_accessor :model_classes
  #@@model_classes = []

  #============================================================
  # Loader Classes
  #============================================================
  mattr_accessor :loader_classes; @@loader_classes = []
  mattr_accessor :loader_depends; @@loader_depends = {}

  #============================================================
  # Accessors for full paths
  #============================================================
  def self.skiima_path
    File.join(project_root, class_variable_get(:@@skiima_path))
  end

  def self.skiima_config_file
    File.join(skiima_path, class_variable_get(:@@skiima_config_file))
  end

  def self.depends_config_file
    File.join(skiima_path, class_variable_get(:@@depends_config_file))
  end

  def self.database_config_path
    File.join(project_root, class_variable_get(:@@database_config_path))
  end

  def self.locale_path
    File.join(project_root, class_variable_get(:@@locale_path))
  end

  def self.locale_file
    File.join(locale_path, "skiima.#{locale.to_s}.yml")
  end

  #============================================================
  # Other Methods
  #============================================================
  def self.get_all_subclasses(subclasses)
    #for now, i'm not going to worry about recursion
    subclasses += subclasses.each_with_object(Array.new) do |klass, sk|
      puts "#{klass.name}: #{klass.subclasses.any?}"
      sk += get_all_subclasses(klass.subclasses) if klass.subclasses
    end
  end

  def self.supported_object_classes(db_adapter_sym)
    sql_object_subclasses = Skiima::SqlObject::Base.subclasses
    sql_object_subclasses.each_with_object(Array.new) do |klass, supported_classes|
      klass_sym = klass.relative_name.underscore.to_sym
      supported_classes[klass_sym] = klass if @@supported_objects[db_adapter_sym].include? (klass_sym)
    end
  end

  def self.supported_dependency_reader_classes
    Skiima::Dependency::Reader.subclasses.each_with_object(Array.new) do |klass, supported_classes|
      klass_sym = klass.relative_name.underscore.to_sym
      supported_classes[klass_sym] = klass if @@supported_dependency_readers.include? (klass_sym)
    end
  end

  #============================================================
  # Error output when debug mode is on
  #============================================================
  def self.puts(str)
    puts str if debug
  end
end