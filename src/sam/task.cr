module Sam
  class Task
    @parent : Namespace
    @deps : Array(String)
    @block : (-> Void) | (Task -> Void) | (Task, Args -> Void)
    @description : String?
    @invoked : Bool = false
    getter name : String

    def initialize(@block, @deps, @parent, @name)
    end

    def initialize(@block, @deps, @parent, @name, @description = nil)
    end

    def invoked?
      @invoked
    end

    def reenable
      @invoked = false
    end

    def path
      @parent.path + @name
    end

    def description
      @description || ""
    end

    # Launch current task. Prerequisites are invoked first.
    def call(args : Args)
      @invoked = true
      @deps.each { |name| invoke(name) }
      case @block.arity
      when 0
        @block.as(-> Void).call
      when 1
        @block.as(Task -> Void).call(self)
      when 2
        @block.as(Task, Args -> Void).call(self, args)
      else
        raise "Wrong task block arity - #{@block.arity} and maximum is 2."
      end
    end

    # Invoke the task if it is needed.
    def invoke(name, args : Args)
      t = find!(name)
      return if t.invoked?
      t.call(args)
    end

    def invoke(name, hash : Args::AllowedHash)
      t = find!(name)
      return if t.invoked?
      t.call(Args.new(hash, [] of Args::AllowedTypes))
    end

    def invoke(name, hash : Args::AllowedHash, arr : Array(Args::AllowedTypes))
      t = find!(name)
      return if t.invoked?
      t.call(Args.new(hash, arr))
    end

    def invoke(name, *args)
      t = find!(name)
      return if t.invoked?
      t.not_nil!.call(Args.new(Args::AllowedHash.new, args.to_a))
    end

    # Invoke the task even if it has been invoked.
    def execute(name, args : Args)
      find!(name).call(args)
    end

    def execute(name, hash : Args::AllowedHash)
      find!(name).call(Args.new(hash, [] of Args::AllowedTypes))
    end

    def execute(name, hash : Args::AllowedHash, arr : Array(Args::AllowedTypes))
      find!(name).call(Args.new(hash, arr))
    end

    def execute(name, *args)
      find!(name).not_nil!.call(Args.new(Args::AllowedHash.new, args.to_a))
    end

    def find!(name)
      t = @parent.find(name)
      raise "Task #{name} was not found" unless t
      t.not_nil!
    end
  end
end
