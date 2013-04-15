require "skiima"
require "rails"

module Skiima
  class Railtie < Rails::Railtie
    rake_tasks do
      load "skiima/railties/skiima.rake"
    end
  end
end
