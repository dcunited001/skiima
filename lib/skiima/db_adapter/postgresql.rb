module Skiima
  class DbAdapter::Postgresql < DbAdapter::Base

    def supported_objects
      super + [:rule, :trigger]
    end
  end
end
