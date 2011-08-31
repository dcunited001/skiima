module Skiima
  class Runner

    attr_accessor :db_adapter

    def initialize(options = {})
      # Want to eventually get rid of the evals
      db_adapter = eval("DbAdapter::#{options[:db_adapter].capitalize}.new")
    end

    def create_sql_objects
      # database.yml - load the config for the necessary environment
          # the environment should already be loaded so i shouldn't have to do anything
            # where is this ino stored?
          # pick database adapters based on environment and database.yml options
      # skiima.yml - load Skiima options
      # depends.yml - get the proper dependency load order
    end

    def drop_sql_objects
      # database.yml - load the config for the necessary environment
      # skiima.yml - load Skiima options
      # depends.yml - get the proper dependency load order (and reverse it)
    end
  end
end