module Sam
  class Args
    alias ALLOWED_HASH = Hash(String, ALLOWED_TYPES)
    alias ALLOWED_TYPES = String | Int32 | Float64

    @arr = [] of ALLOWED_TYPES
    @named_args = {} of String => ALLOWED_TYPES

    def initialize
    end

    def initialize(args : Array(String))
      parse(args)
    end

    def initialize(_named_args : ALLOWED_HASH, _arr = [] of ALLOWED_TYPES)
      h = ALLOWED_HASH.new
      _named_args.each { |k, v| h[k] = v.as(ALLOWED_TYPES) }
      @named_args = h
      @arr = _arr.map { |e| e.as(ALLOWED_TYPES) }
    end

    def raw
      @arr
    end

    def named
      @named_args
    end

    def size
      @arr.size + @named_args.size
    end

    def [](index : Int32)
      @arr[index]
    rescue e
      raise ArgumentError.new("Missing argument with index #{index}")
    end

    def [](name : String | Symbol)
      @named_args[name.to_s]
    rescue e
      raise ArgumentError.new("Missing argument with name #{name}")
    end

    def []?(index : Int32) : ALLOWED_TYPES | Nil
      @arr[index]?
    end

    def []?(name : String | Symbol) : ALLOWED_TYPES | Nil
      @named_args[name.to_s]?
    end

    private def parse(args)
      skip = false
      args.each_with_index do |str, i|
        if skip
          skip = false
          next
        end

        name = option_name(str)
        if name
          value = option_value(str)
          unless value
            value = (args.size > i + 1) ? option_value(args[i + 1], false) : ""
            skip = true
          end
          @named_args[name] = value || ""
        else
          @arr << str
        end
      end
    end

    private def option_name(str)
      if str[0] == '-'
        str[1..-1]
      elsif str =~ /=/
        str.split("=")[0]
      end
    end

    private def option_value(str : String, same_string = true)
      if same_string
        if str =~ /=/
          str.split("=")[1]
        elsif str[0] != '-'
          str
        end
      elsif str[0] != '-' && !(str =~ /=/)
        str
      end
    end

    private def option_value(str : Nil, same_string = true); end
  end
end
