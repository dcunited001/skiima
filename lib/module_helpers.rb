# copy and paste from Active Support
#   (i don't want active support as a dependency')
module ModuleHelpers
  def set_mod_accessors(hash)
    hash.each_pair do |k,v|
      mattr_accessor(k)
      class_variable_set("@@#{k.to_s}", v)
    end
  end
end