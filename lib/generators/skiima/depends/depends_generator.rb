
module Skiima
  module Generators
    class DependsGenerator < Rails::Generators::Base
      desc "Creates necessary files and folders in 'db/skiima'.  Run `rails g skiima:install` first."
      source_root(File.expand_path('../../templates', __FILE__))

      def create_depends_config
        # For now, template
        template "depends.yml", File.join(Skiima.skiima_path, 'depends.yml')
      end

      def create_depends_files
        #later create necessary dependency files
      end

      def some_notes
        puts <<-END
==================================================
Some More Notes:


==================================================
END
      end
    end
  end
end

