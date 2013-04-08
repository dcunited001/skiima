# encoding: utf-8
module Skiima
  class Logger
    extend Forwardable

    delegate debug: :logger
    delegate info: :logger
    delegate warn: :logger
    delegate error: :logger
    delegate fatal: :logger

    attr_accessor :logger, :logging_out, :logging_level

    def initialize(opts = {})
      @logging_out = get_logger_out(opts[:logging_out])
      @logging_level = get_logger_level(opts[:logging_level])
      create_logger
    end

    private

    def get_logger_out(str)
      case str
        when /STDOUT/i then ::STDOUT
        when /STDERR/i then ::STDERR
        else File.join(root_path, str)
      end
    end

    def get_logger_level(str)
      case str
        when '4', /fatal/i then ::Logger::FATAL
        when '3', /error/i then ::Logger::ERROR
        when '2', /warn/i  then ::Logger::WARN
        when '1', /info/i  then ::Logger::INFO
        when '0', /debug/i then ::Logger::DEBUG
        else ::Logger::ERROR
      end
    end

    def create_logger
      @logger = ::Logger.new(logging_out)
      @logger.level = logging_level
    end

  end

  module LoggerHelpers
    def log_message(logger, msg)
      logger.debug msg
    end
  end
end

