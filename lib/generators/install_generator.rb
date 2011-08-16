module Skiima
  module Generators
    class InstallGenerator
      include Rails::Generators::Migration

      desc "Sets up Skiima and configuration YAML files.  Creates migration file."

      def copy_skiima_config
        copy_file "../../config/skiima.yml", "config/skiima.en.yml"
      end

      def copy_locale
        copy_file "../../config/locales/en.yml", "config/locales/skiima.en.yml"
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
      #need a function or method of giving
      #   the generated migration a high enough number
      #   so that all the necessary tables have been
      #   created by the time Skiima would create
      #   all the dependent objects


      #def self.last_migration_number(dirname)
      #  if ActiveRecord::Base.timestamped_migrations
      #    Time.new.utc.strftime("%Y%m%d%H%M%S")
      #  else
      #    "%.3d" % (current_migration_number(dirname) + 1)
      #  end
      #end
    end
  end
end
