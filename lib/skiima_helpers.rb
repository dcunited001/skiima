# encoding: utf-8
module SkiimaHelpers
  def symbolize_keys(hash)
    hash.inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end
end

module ModuleHelpers
  def set_defaults(sym, val)
  	add_module_attr_reader(sym)
  	add_module_attr_writer(sym)
  	class_variable_set("@@#{sym.to_s}", val)
  end

  alias_method :set_default, :set_defaults

  def add_module_attr_writer(sym)
    class_eval(<<-EOS, __FILE__, __LINE__ + 1)
      def self.#{sym}=(obj)
        @@#{sym} = obj
      end
    EOS

    class_eval(<<-EOS, __FILE__, __LINE__ + 1)
      def #{sym}=(obj)
        @@#{sym} = obj
      end
    EOS
  end

  def add_module_attr_reader(sym)
    class_eval(<<-EOS, __FILE__, __LINE__ + 1)
      @@#{sym} = nil unless defined? @@#{sym}

      def self.#{sym}
        @@#{sym}
      end
    EOS

    class_eval(<<-EOS, __FILE__, __LINE__ + 1)
      def #{sym}
        @@#{sym}
      end
    EOS
  end
end