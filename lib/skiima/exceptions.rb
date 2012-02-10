module Skiima
  class BaseException < ::StandardError; end
  class MissingFileException < BaseException; end
  class SqlGroupNotFound < BaseException; end
  class SqlScriptNotFound < BaseException; end
end
