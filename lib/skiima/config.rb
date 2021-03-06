# encoding: utf-8
module Skiima
  module Config

    def config
      @config ||= (Skiima::Config::Struct.new(defaults.to_hash))
    end

    def config=(struct)
      @config = struct
    end

    def full_scripts_path(root = self.root_path, config = self.scripts_path)
      File.join(root, config)
    end

    def full_database_path(root = self.root_path, config = self.config_path, db = self.database_yml)
      File.join(root, config, db)
    end

    def full_dependencies_path(root = self.root_path, config = self.scripts_path, dependencies = self.dependencies_yml)
      File.join(root, config, dependencies)
    end

    def read_sql_file(folder, file)
      File.open(File.join(Skiima.full_scripts_path, folder, file)).read
    end

    def read_db_yml(file)
      symbolize_keys(read_yml_or_throw(file, MissingFileException, "#{Skiima.msg('errors.open_db_yml')} #{file}"))
    end

    def read_dependencies_yml(file)
      symbolize_keys(read_yml_or_throw(file, MissingFileException, "#{Skiima.msg('errors.open_dependencies_yml')} #{file}"))
    end

    def read_yml_or_throw(file, errclass, errmsg)
      input = File.read(file)
      eruby = Erubis::Eruby.new(input)
      symbolize_keys(YAML::load(eruby.result(binding()))) || {}
    rescue => ex
      raise errclass, errmsg
    end

    def symbolize_keys(hash)
      hash.inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end
    end

    def interpolate_sql(char, sql, vars = {})
      vars.inject(sql) { |m,(k,v)| m.gsub("#{char}#{k.to_s}", v) }
    end

    def method_missing(method, *args, &block)
      config.respond_to?(method) ? config.send(method, *args) : super
    end
  end
end
