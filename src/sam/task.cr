require "./execution"

module Sam
  class Task
    include Execution

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

    # Launch current task.
    #
    # Prerequisites are invoked before target task.
    def call(args : Args)
      @invoked = true
      case @block.arity
      when 0, 1
        @deps.each { |name| invoke(name) }
      when 2
        @deps.each { |name| invoke(name, args) }
      else
        raise "Wrong task block arity - #{@block.arity} and maximum is 2."
      end

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

    def find(name : String)
      @parent.find(name)
    end
  end
end
