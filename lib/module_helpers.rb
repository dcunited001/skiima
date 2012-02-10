# encoding: utf-8

#shamelessly stolen from active support, i know
module ModuleHelpers
  def set_mod_accessors(hash)
    hash.each_pair do |k,v|
      #mattr_accessor(k)
      add_module_attr_reader(k)
      add_module_attr_writer(k)
      class_variable_set("@@#{k.to_s}", v)
    end
  end

  def add_module_attr_writer(*syms)
    syms.each do |sym|
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
  end

  def add_module_attr_reader(*syms)
    syms.each do |sym|
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
end