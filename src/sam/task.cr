module Sam
  class Task
    @parent : Namespace
    @deps : Array(String)
    @block : (-> Void) | (Task -> Void) | (Task, Args -> Void)
    @description : String?
    getter name : String

    def initialize(@block, @deps, @parent, @name)
    end

    def initialize(@block, @deps, @parent, @name, @description = nil)
    end

    def path
      @parent.path + @name
    end

    def description
      @description || ""
    end

    def call(args : Args)
      @deps.each { |name| invoke(name) }
      case @block.arity
      when 0
        @block.as(-> Void).call
      when 1
        @block.as(Task -> Void).call(self)
      when 2
        @block.as(Task, Args -> Void).call(self, args)
      end
    end

    def invoke(name, args : Args)
      t = find!(name)
      t.call(args)
    end

    def invoke(name, hash : Args::ALLOWED_HASH)
      t = find!(name)
      t.call(Args.new(hash, [] of Args::ALLOWED_TYPES))
    end

    def invoke(name, hash : Args::ALLOWED_HASH, arr : Array(Args::ALLOWED_TYPES))
      t = find!(name)
      t.call(Args.new(hash, arr))
    end

    def invoke(name, *args)
      t = find!(name)
      t.not_nil!.call(Args.new(Args::ALLOWED_HASH.new, args.to_a))
    end

    def find!(name)
      t = @parent.find(name)
      raise "Task #{name} was not found" unless t
      t.not_nil!
    end
  end
end
