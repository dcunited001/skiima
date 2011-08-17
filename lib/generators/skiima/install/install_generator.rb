require 'rails/generators/migration'

module Skiima
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      SKIIMA_DIR_LOC = 'db/skiima'
      SKIIMA_DIR_EXISTS = "Skiima directory already exists at #{SKIIMA_DIR_LOC}"
      SKIIMA_DIR_CREATE = "Creating Skiima Directory at #{SKIIMA_DIR_LOC}"
      SKIIMA_DIR_ERROR = "Errors Creating Skiima Directory at #{SKIIMA_DIR_LOC}"

      desc "Sets up Skiima and configuration YAML files.  Creates migration file."
      source_root(File.expand_path('../templates', __FILE__))


      def create_skiima_directory
        if File.exists?(SKIIMA_DIR_LOC)
          puts SKIIMA_DIR_EXISTS
        else
          begin
            puts SKIIMA_DIR_CREATE
            mkdir 'db/skiima'
          rescue
            puts SKIIMA_DIR_ERROR
            puts $!
          end
        end
      end

      def copy_depends_config
        template "depends.yml", "config/depends.yml"
      end

      def copy_skiima_config
        template "skiima.yml", "config/skiima.yml"
      end

      def copy_locale
        copy_file "../../../../config/locales/en.yml", "config/locales/skiima.en.yml"
      end

      def notes
        puts <<-END
==================================================
Skiima has been succesfully installed!

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
