
module Skiima
  module Generators
    class DependsGenerator < Rails::Generators::Base
      desc "Creates necessary files and folders in 'db/skiima'.  Run `rails g skiima:install` first."
      source_root(File.expand_path('../../templates', __FILE__))

      attr_accessor :config

      #best way to handle different arguments here?
      def load_config
        @config = Skiima::LoaderConfig.new
      end

      def create_depends_files
        #internationalization
        #I18n.t("devise.registrations.reasons.#{reason}", :default => reason)

        # instantiate the dependency reader configured
        #   (to be implemented with the proper format for each dependency reader later)
        # configured_reader_class = Skiima.supported_dependency_reader_classes[yml[:load_order]] if options[:load_order]

        depends = Skiima.loader_depends
        depends.keys.each { |table_name|
          dependent_objects = depends[table_name]

          empty_directory File.join(Skiima.skiima_path, table_name)
          dependent_objects.keys.each {|script| empty_file File.join(Skiima.skiima_path, table_name, "#{script}.sql") }
        }
      end

      def some_notes
        puts <<-END
==================================================

Some More Notes:
  - Notey
  _ Note

==================================================
END
      end

      private

    end
  end
end

