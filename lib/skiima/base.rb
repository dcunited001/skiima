# encoding: utf-8
module Skiima
  # the set of options passed down to the instance of Skiima::Base
  def self.instance_options
    [ :project_root,
      :project_config_path,
      :config_file,
      :database_config_file,
      :skiima_path,
      :depends_file,
      :locale_path,

      :load_order,
      :locale,
      :debug ]
  end

  class Base
    attr_accessor *Skiima.instance_options

    def initialize(options = {})
      Skiima.instance_options.each { |opt| instance_variable_set("@#{opt.to_s}", Skiima.send(opt)) }
    end
  end
end