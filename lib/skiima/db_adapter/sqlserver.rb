module Skiima
  class DbAdapter::Sqlserver < DbAdapter::Base

    def supported_objects
      super + [:sp, :trigger, :constraint]
    end
  end
end