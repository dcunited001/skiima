# encoding: utf-8
require 'skiima/version'

require 'yaml'
require 'logger'
require 'fast_gettext'
require 'erubis'
require 'ostruct'
require 'forwardable'

require 'pry'

require 'skiima/config'
require 'skiima/i18n'
require 'skiima/logger'
require 'skiima/loader'
require 'skiima/db_adapters'
require 'skiima/dependency/script'
require 'skiima/dependency/reader'

include FastGettext unless ::Object.included_modules.include?(FastGettext)

module Skiima
  include FastGettext::Translation
  extend Skiima::Config
  extend Skiima::I18n
  extend Skiima::LoggerHelpers

  class << self

    def setup
      yield config
      set_translation_repository
    end

    def defaults
      { root_path: 'specify/in/config/block',
        config_path: 'config',
        database_yml: 'database.yml',
        scripts_path: 'db/skiima',
        depends_yml: 'depends.yml',
        interpolator: '&',
        locale: 'en',
        logging_out: 'STDOUT',
        logging_level: '3' }
    end

    def new(env, opts = {})
      Skiima::Loader.new(env, opts)
    end

    def up(env, *args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      ski = Skiima::Loader.new(env, opts).up(*args, opts)
    ensure
      ski.connection.close if ski && ski.connection
    end

    def down(env, *args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      ski = Skiima::Loader.new(env, opts).down(*args, opts)
    ensure
      ski.connection.close if ski && ski.connection
    end

    def exe_with_connection(db, &block)
      resolver = Skiima::DbAdapters::Resolver.new db
      connection = nil

      begin 
        connection = self.send(resolver.adapter_method, db)
        yield connection
      rescue => ex
        puts "Oh Noes!!"
      ensure
        connection.close
      end
    end

    def method_missing(method, *args, &block)
      config.respond_to?(method) ? config.send(method, *args) : super
    end

  end
end

module Skiima
  class BaseException < ::StandardError; end
  class MissingFileException < BaseException; end
  class SqlGroupNotFound < BaseException; end
  class SqlScriptNotFound < BaseException; end
  class AdapterNotSpecified < BaseException; end
  class LoadError < BaseException; end
  class StatementInvalid < BaseException; end
end