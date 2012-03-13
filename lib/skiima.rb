# encoding: utf-8
require 'skiima/version'

require 'yaml'
require 'logger'
require 'fast_gettext'

#tried to avoid using active_support,
#   but i rely too much on naming conventions
require 'active_support/deprecation'
require 'active_support/dependencies'
require 'module_helpers'

# include FastGettext unless it already is
include FastGettext unless ::Object.included_modules.include?(FastGettext)

module Skiima
  include FastGettext::Translation
  extend ModuleHelpers

  require 'skiima/base'
  require 'skiima/exceptions'
  require 'skiima/runner'

  autoload :DbAdapter, 'skiima/db_adapter'
  autoload :Loader, 'skiima/loader'
  autoload :Dependency, 'skiima/dependency'
  autoload :SqlObject, 'skiima/sql_object/base'
  require 'skiima/sql_object/table'
  require 'skiima/sql_object/index'
  require 'skiima/sql_object/view'
  require 'skiima/sql_object/function'
  require 'skiima/sql_object/sp'
  require 'skiima/sql_object/rule'
  require 'skiima/sql_object/trigger'


  #not sure why this didn't work.
  #Dir[File.join('skiima', 'db_adapter', '**')].each { |rb| require rb if rb != 'base.rb'}
  #Dir[File.join('skiima', 'loader', '**')].each { |rb| require rb if rb != 'base.rb' }
  #Dir[File.join('skiima', 'sql_object', '**')].each { |rb| require rb if rb != 'base.rb' }

  # Dynamically set inheritance in Ruby
  #http://stackoverflow.com/questions/3127069/how-to-dynamically-alter-inheritance-in-ruby


  #============================================================
  # Base Config Paths (Can only override with config block)
  #============================================================
  set_mod_accessors(
    :project_root => 'specify/in/config/block', #must be overridden for now (want gem to really be rails-agnostic)
    :project_config_path => 'config',
    :config_file => 'skiima.yml')

  #============================================================
  # Config Paths (Can override in skiima.yml)
  #============================================================
  set_mod_accessors(
    :database_config_file => 'database.yml',
    :skiima_path => 'db/skiima',
    :depends_file => 'depends.yml')

  #============================================================
  # Config options (Can override in )
  #============================================================
  set_mod_accessors(
    :load_order => 'sequential',
    :locale => 'en',
    :logging_out => '$stdout',
    :logging_level => '3')

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
  #
  # i would like to remove active record completely

  #============================================================
  # Loader Classes
  #============================================================
  set_mod_accessors :loader_classes => [], :loader_depends => {}

  class << self
    def setup
      set_translation_repository
      yield self
    end

    def new(opts = {})
      #Skiima::Base.new(opts)
    end

    #============================================================
    # Implementation methods
    #============================================================
    def up(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      Skiima.new(opts).up(*args)
    end

    def down(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      Skiima.new(opts).down(*args)
    end

    #============================================================
    # Class Variable Accessors for Module
    #============================================================
    def get_path(path, get_relative_path = true, absolute_path = nil)
      (get_relative_path && path) || (File.join(absolute_path, path))
    end

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

    def read_yaml_or_throw(file, errclass, errmsg)
      yaml = begin
        YAML::load_file(file) || {}
      rescue => ex
        raise errclass, errmsg
      end

      Skiima.symbolize_keys(yaml)
    end

    #============================================================
    # Error output when debug mode is on
    #============================================================
    #def puts(level, str)
    #  puts str if level >= logging_level
    #end

    def message(*args)
      locale = args.last.is_a?(Symbol) ? args.pop : default_locale

      lookup = args.join('.')
      Skiima._(lookup)
    end

    def default_locale
      ::Skiima.locale
    end

    def set_translation_repository
      FastGettext.add_text_domain('skiima', :path => File.join(File.dirname(__FILE__), 'skiima', 'locales'), :type => :yaml)
      Skiima.text_domain = 'skiima'
      Skiima.locale = locale.to_s
    end
  end
end
