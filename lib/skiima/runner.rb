module Skiima
  class Runner

    attr_accessor :db_adapter
    db_adapter = DbAdapter::Postgresql.new

    def create_sql_objects
      # database.yml - load the config for the necessary environment
        #pick database adapters based on environment and database.yml options
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