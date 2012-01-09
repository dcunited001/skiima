# encoding: utf-8
require "skiima/version"
require 'yaml'

#tried to avoid using active_support,
#   but i rely too much on naming conventions
require 'active_support/deprecation'
require 'active_support/dependencies'
require 'module_helpers'

module Skiima
  extend ModuleHelpers

  require 'skiima/base'
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

  # Dynamically set inheritance in Ruby
  #http://stackoverflow.com/questions/3127069/how-to-dynamically-alter-inheritance-in-ruby

  #============================================================
  # Config locations
  #============================================================
  set_mod_accessors(
    :project_root => 'specify/in/config/block', #must be overridden for now (want gem to really be rails-agnostic)
    :project_config_path => 'config',
    :config_file => 'skiima.yml',
    :database_config_file => 'database.yml',
    :skiima_path => 'db/skiima',
    :depends_file => 'depends.yml',
    :locale_path => 'config/locales')

  #============================================================
  # Config options
  #============================================================
  set_mod_accessors(
    :load_order => :sequential,
    :locale => :en,
    :debug => false)
    #logging => log_level?

  #============================================================
  # Supported Databases & Objects (can be overridden in config block)
  #============================================================
  set_mod_accessors(
    :supported_dependency_readers => [:sequential, :tree],
    :supported_databases => [:mysql, :postgresql, :sqlserver],
    :supported_objects => {
      :mysql => [:table, :view, :index, :function, :trigger],
      :postgresql => [:table, :view, :index, :function, :rule, :trigger],
      :sqlserver => [:table, :view, :index, :function, :sp, :trigger] } )

  #============================================================
  # Active Record Models
  #============================================================
  #mod_attr_accessor :model_classes
  #@@model_classes = []

  #============================================================
  # Loader Classes
  #============================================================
  set_mod_accessors :loader_classes => [], :loader_depends => {}

  #============================================================
  # Accessors for full paths
  #============================================================

  class << self
    def setup
      yield self
    end

    define_method(:project_config_path)   { File.join(project_root, class_variable_get(:@@project_config_path)) }
    define_method(:config_file)           { File.join(project_config_path, class_variable_get(:@@config_file)) }
    define_method(:database_config_file)  { File.join(project_config_path, class_variable_get(:@@database_config_file)) }
    define_method(:skiima_path)           { File.join(project_root, class_variable_get(:@@skiima_path)) }
    define_method(:depends_file)          { File.join(skiima_path, class_variable_get(:@@depends_file)) }
    define_method(:locale_path)           { File.join(project_root, class_variable_get(:@@locale_path)) }
    define_method(:locale_file)           { File.join(locale_path, "skiima.#{locale.to_s}.yml") }

    #============================================================
    # Other Methods
    #============================================================
    def get_all_subclasses(subclasses)
      #for now, i'm not going to worry about recursion
      subclasses += subclasses.each_with_object(Array.new) do |klass, sk|
        puts "#{klass.name}: #{klass.subclasses.any?}"
        sk += get_all_subclasses(klass.subclasses) if klass.subclasses
      end
    end

    def supported_object_classes(db_adapter_sym)
      sql_object_subclasses = Skiima::SqlObject::Base.subclasses
      sql_object_subclasses.each_with_object(Array.new) do |klass, supported_classes|
        klass_sym = klass.relative_name.underscore.to_sym
        supported_classes[klass_sym] = klass if @@supported_objects[db_adapter_sym].include? (klass_sym)
      end
    end

    def supported_dependency_reader_classes
      Skiima::Dependency::Reader.subclasses.each_with_object(Array.new) do |klass, supported_classes|
        klass_sym = klass.relative_name.underscore.to_sym
        supported_classes[klass_sym] = klass if @@supported_dependency_readers.include? (klass_sym)
      end
    end

    #============================================================
    # Error output when debug mode is on
    #============================================================
    def puts(str)
      puts str if debug
    end
  end
end