require 'argive'
require 'rails'

module Skiima
  class Railtie < Rails::Railtie
    rake_tasks do
      require File.join('lib', 'tasks', 'skiima.rake')
    end
  end
end