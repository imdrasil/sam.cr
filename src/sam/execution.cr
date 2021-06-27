require "./exceptions"

module Sam
  module Execution
    abstract def find(path : String)

    def find!(path : String)
      task = find(path)
      raise NotFound.new(path) if task.nil?

      task
    end

    # Invoke the task if it is needed.
    def invoke(name, args : Args)
      t = find!(name)
      return if t.invoked?

      t.call(args)
    end

    def invoke(name, hash : Args::AllowedHash)
      invoke(name, Args.new(hash, [] of Args::AllowedTypes))
    end

    def invoke(name, hash : Args::AllowedHash, arr : Array(Args::AllowedTypes))
      invoke(name, Args.new(hash, arr))
    end

    def invoke(name, *args)
      invoke(name, Args.new(Args::AllowedHash.new, args.to_a))
    end

    # Invoke the task even if it has been invoked.
    def execute(name, args : Args)
      find!(name).call(args)
    end

    def execute(name, hash : Args::AllowedHash)
      execute(name, Args.new(hash, [] of Args::AllowedTypes))
    end

    def execute(name, hash : Args::AllowedHash, arr : Array(Args::AllowedTypes))
      execute(name, Args.new(hash, arr))
    end

    def execute(name, *args)
      execute(name, Args.new(Args::AllowedHash.new, args.to_a))
    end
  end
end
