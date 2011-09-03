module Skiima
  class Runner
    attr_accessor :config
    attr_accessor :db_adapter
    attr_accessor :loader_classes
    attr_accessor :loaders

    def initialize(options = {})
      Skiima.puts "==[ Reading Configuration ]=="
      @config = Skiima::LoaderConfig.new

      Skiima.puts "==[ Creating DB Adapter ]=="
      @db_adapter = DbAdapter::Base.get_adapter_class(options[:db_adapter]).new if options[:db_adapter].to_s
      @db_adapter ||= DbAdapter::Postgresql.new

      Skiima.puts "==[ Creating Loaders ]=="
      @loader_classes = get_class_loaders
      @loaders = @loader_classes.map do |lc|
        lc.new(
            :db_adapter => @db_adapter,
            :depends_config => Skiima.loader_depends[lc.table_name],
            :load_order => Skiima.load_order)
      end
    end

    def create_sql_objects
      Skiima.puts "==[ Connecting to DB ]=="

      Skiima.puts "==[ Creating Objects ]=="
      @loaders.each { |loader| loader.create }
    end

    def drop_sql_objects
      Skiima.puts "==[ Connecting to DB ]=="

      Skiima.puts "==[ Dropping Objects ]=="
      @loaders.each { |loader| loader.drop }
    end

    # provide methods options to run specific Loaders
  end
end