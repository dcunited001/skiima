module Skiima
  module Config

    class Struct < OpenStruct
      def initialize(opts = {})
        @table = Skiima.symbolize_keys(opts)
        @table.each_key { |k,v| new_ostruct_member(k) }
      end

      def new_ostruct_member(name)
        name = convert_key(name)
        unless self.respond_to?(name)
          self.instance_eval <<EOS
    def #{name.to_s}
      v = @table[:#{name.to_s}]
      if v.is_a?(Hash)
        self.class.new(v)
      else
        v
      end
    end

    def #{name.to_s}=(x)
      modifiable[:#{name.to_s}] = x
    end
EOS
        end
        name
      end

      def method_missing(mid, *args, &block)
        mname, len = mid.id2name, args.length

        case
        when (mname.chomp!('=') && (mid != :[]=))
          raise_argument_error(len, caller(1)) if len != 1
          modifiable[new_ostruct_member(mname)] = args[0]
        when (len == 0 && (mid != :[]) && block_given?)
          cs = self.class.new(Hash.new).ostruct_eval(&block)
          modifiable[new_ostruct_member(mname)] = cs
        when (len == 0 && mid != :[])
          @table[mid]
        when (len == 1 && mid != :[])
          modifiable[new_ostruct_member(mname)] = args[0]
        else raise_no_method_error(mid, caller(1))
        end

      end

      def [](key)
        @table[key]
      end

      def []=(key,val)
        modifiable[key] = val
      end

      def slice(*keys)
        keys.inject(Hash.new) { |m,k| m[k] = @table[k] if @table.key?(k); m }
      end

      def merge(hash)
        hash.each { |k,v| self[k] = v; new_ostruct_member(k) unless self.respond_to? k }
        self
      end

      def to_hash
        @table
      end

      def convert_key(key)
        key.kind_of?(Symbol) ? key : (key.to_sym rescue key)
      end

      private

      def raise_argument_error(len, caller)
        raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller
      end

      def raise_no_method_error(mid, caller)
        raise NoMethodError, "undefined method `#{mid}' for #{self}", caller
      end
    end

  end
end