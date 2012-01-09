# encoding: utf-8
class CreateSkiima < ActiveRecord::Migration
  def self.up
    Skiima::Runner.create_sql_objects
  end

  def self.down
    Skiima::Runner.drop_sql_objects
  end
end

