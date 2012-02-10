# encoding: utf-8
module Skiima
  class Logger
    attr_accessor :out, :level
    attr_accessor :file

    STDOUT = '$stdout'
    def initialize(level, out = STDOUT)
      @out = out
      @level = level
      unless out == STDOUT
        begin
          @file = File.open(out, 'w+')
        rescue
          raise MissingFileException, "Could not open Skiima Log File! #{out}"
        end
      end
    end

    def write_msg(msg)
      if file
        file.write(msg)
      else
        puts msg
      end
    end

    def debug(lvl, msg)
      if lvl <= level
        write_msg(msg)
      end
    end

    def error(msg)
      write_msg(msg)
      close_file if file
    end

    private

    def close_file
      @file.close
    end
  end
end