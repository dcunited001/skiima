# encoding: utf-8
require 'skiima/version'

require 'yaml'
require 'logger'
require 'fast_gettext'
require 'erubis'
require 'ostruct'
require 'forwardable'

require 'skiima/config'
require 'skiima/config/struct'
require 'skiima/i18n'
require 'skiima/logger'
require 'skiima/loader'
require 'skiima/db/resolver'
require 'skiima/db/connector'
require 'skiima/dependency/script'
require 'skiima/dependency/reader'

include FastGettext unless ::Object.included_modules.include?(FastGettext)

module Skiima
  include FastGettext::Translation
  extend Skiima::Config
  extend Skiima::I18n
  extend Skiima::LoggerHelpers

  class << self
    extend Forwardable
    delegate new: Skiima::Loader
  end

  def self.setup
    yield config
    set_translation_repository
  end

  def self.defaults
    { root_path: 'specify/in/config/block',
      config_path: 'config',
      database_yml: 'database.yml',
      scripts_path: 'db/skiima',
      dependencies_yml: 'dependencies.yml',
      interpolator: '&',
      locale: 'en',
      logging_out: 'STDOUT',
      logging_level: '3' }
  end

  def self.up(env, *args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    ski = Skiima::Loader.new(env, opts).up(*args, opts)
  ensure
    ski.connector.disconnect! if ski && ski.connector
  end

  def self.down(env, *args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    ski = Skiima::Loader.new(env, opts).down(*args, opts)
  ensure
    ski.connector.disconnect! if ski && ski.connector
  end

  def self.exe_with_connection(db, &block)
    resolver = Skiima::Db::Resolver.new db
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

  private

  def self.method_missing(method, *args, &block)
    config.respond_to?(method) ? config.send(method, *args) : super
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