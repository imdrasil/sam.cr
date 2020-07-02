module Sam
  class Namespace
    getter name : String
    @parent : Namespace?
    @namespaces = {} of String => Namespace
    @tasks = {} of String => Task
    @@description : String? = nil

    def initialize(@name, @parent)
    end

    def path
      if @parent
        @parent.not_nil!.path + @name + ":"
      else
        # this is a root namespace
        ""
      end
    end

    # Sets description to the next defined task.
    def desc(description : String)
      @@description = description
    end

    # Defines nested namespace.
    def namespace(name)
      with touch_namespace(name) yield
      @namespaces[name]
    end

    def touch_namespace(name)
      @namespaces[name] ||= Namespace.new(name, self)
    end

    # Defines new task.
    def task(name, dependencies = [] of String, &block : Task, Args -> Void)
      task = (@tasks[name] = Task.new(block, dependencies, self, name, @@description))
      @@description = nil
      task
    end

    def namespaces(name)
      @namespaces[name]?
    end

    def tasks(name)
      @tasks[name]?
    end

    def all_tasks
      tasks = @tasks.values
      @namespaces.each { |_, namespace| tasks = tasks + namespace.all_tasks }
      tasks
    end

    def find(path : String)
      raise ArgumentError.new("Path can't be empty") if path.empty?

      find(path.split(":"))
    end

    protected def find(path : Array(String))
      if path.size == 1
        t = tasks(path[0])
        return t if t
      else
        n = namespaces(path[0])
        t = n.try(&.find(path[1..-1]))
        return t if t
      end
      @parent.try(&.find(path))
    end
  end
end
