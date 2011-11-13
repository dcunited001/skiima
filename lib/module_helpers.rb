# copy and paste from Active Support
#   (i don't want active support as a dependency')
module ModuleHelpers
  def mod_attr_reader(*syms)
    syms.each do |sym|
      class_eval("
        @@#{sym} = nil unless defined?
        @@#{sym}
        def self.#{sym}
          @@#{sym}
        end", __FILE__, __LINE__ + 1)

      class_eval("
        def #{sym}
          @@#{sym}
        end", __FILE__, __LINE__ + 1)
    end
  end

  def mod_attr_writer(*syms)
    syms.each do |sym|
      class_eval("
        def self.#{sym}=(obj)
          @@#{sym} = obj
        end", __FILE__, __LINE__ + 1)

      class_eval(
        "def #{sym}=(obj)
          @@#{sym} = obj
        end", __FILE__, __LINE__ + 1)
    end
  end

  def mod_attr_accessor(*syms)
    mod_attr_reader(*syms)
    mod_attr_writer(*syms)
  end

  def set_mod_accessors(hash)
    hash.each_pair do |k,v|
      mod_attr_accessor(k)
      class_variable_set("@@#{k.to_s}", v)
    end
  end
end