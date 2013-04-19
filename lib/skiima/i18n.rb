# encoding: utf-8
module Skiima
  module I18n

    def locale
      @config[:locale] ||= :en
    end

    def default_locale
      ::Skiima.locale
    end

    def msg(*args)
      # TODO: change to use config.locale
      locale = args.last.is_a?(Symbol) ? args.pop : default_locale
      lookup = args.join('.')
      Skiima._(lookup)
    end

    def set_translation_repository
      FastGettext.add_text_domain('skiima', :path => File.join(File.dirname(__FILE__), 'skiima', 'locales'), :type => :yaml)
      Skiima.text_domain = 'skiima'
      Skiima.locale = locale
    end

  end
end
