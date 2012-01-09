# encoding: utf-8
require 'rails/generators/migration'

module Skiima
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      desc "Sets up Skiima and configuration YAML files.  Creates migration file for SQL objects that runs after all other migrations."
      source_root(File.expand_path('../../templates', __FILE__))

      def create_skiima_directory
        empty_directory Skiima.skiima_path
      end

      def copy_skiima_config
        template "skiima.yml", File.join(Skiima.skiima_path, 'skiima.yml')
      end

      def copy_locale
        copy_file "locales/en.yml", File.join(Skiima.locale_path, 'skiima.en.yml')
      end

      def copy_migration
        migration_template 'migration.rb', 'db/migrate/create_skiima.rb'
      end

      def copy_initializer
        copy_file 'skiima.rb', 'config/initializers/skiima.rb'
      end

      def create_depends_config
        # For now, template
        template "depends.yml", File.join(Skiima.skiima_path, 'depends.yml')
      end

      def some_notes
        puts <<-END
==================================================

Skiima has been succesfully installed!

Next, you need to configure the classes in config/skiima.yml
    And then run `rails generate skiima:depends`
    View config/skiima.yml for Exemplia Gratis

Please note that Skiima is in its very early stages.
    Also, this is my first gem.

I'd love advice if you have it.
    And if you'd like to contribute,
    Please visit http://www.github.com/dcunited001/Skiima

Peace in the Middle East
  (and also Kashmir),
David Conner

==================================================
END
      end

      private

      #need a way to get the generated migration a high enough number
      #   so that all the necessary tables have been created by the
      #   time Skiima would create all the dependent objects
      def self.next_migration_number(dirname)
        '20121223235959'

        #if ActiveRecord::Base.timestamped_migrations
        #  Time.new.utc.strftime("%Y%m%d%H%M%S")
        #else
        #  "%.3d" % (current_migration_number(dirname) + 1)
        #end
      end
    end
  end
end
