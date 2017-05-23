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
        ""
      end
    end

    def desc(description : String)
      @@description = description
    end

    def namespace(name)
      with touch_namespace(name) yield
    end

    def touch_namespace(name)
      @namespaces[name] ||= Namespace.new(name, self)
    end

    def task(name, dependencies = [] of String, &block : Task, Args -> Void)
      @tasks[name] = Task.new(block, dependencies, self, name, @@description)
      @@description = nil
    end

    def namespaces(name)
      @namespaces[name]?
    end

    def tasks(name)
      @tasks[name]?
    end

    def all_tasks
      tasks = @tasks.values
      @namespaces.each { |name, n| tasks = tasks + n.all_tasks }
      tasks
    end

    def find(path)
      parts = path.split(":")
      count = parts.size
      n = self
      parts[0...-1].each do |name|
        n = n.namespaces(name)
        unless n
          return @parent ? @parent.not_nil!.find(path) : nil
        end
      end
      t = n.not_nil!.tasks(parts[-1])
      return t if t
      @parent ? @parent.not_nil!.find(path) : nil
    end
  end
end
