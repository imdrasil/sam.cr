require "./sam/*"

module Sam
  extend Execution

  VERSION = "0.4.2"

  # Task separation symbol used in command line.
  TASK_SEPARATOR = "@"

  @@root_namespace = Namespace.new("root", nil)

  # :nodoc:
  def self.root_namespace
    @@root_namespace
  end

  def self.namespace(name : String)
    n = @@root_namespace.touch_namespace(name)
    with n yield
  end

  def self.desc(description)
    @@root_namespace.desc(description)
  end

  # delegates call to root namespace
  def self.task(name, dependencies = [] of String, &block : Task, Args -> Void)
    @@root_namespace.task(name, dependencies, &block)
  end

  def self.find(path : String)
    @@root_namespace.find(path)
  end

  def self.invoke(name, args : Array(String))
    invoke(name, Args.new(args))
  end

  def self.help
    return puts "Hm, nothing to do..." if ARGV.empty?

    process_tasks(ARGV.clone)
  rescue e : NotFound
    puts e.message
    exit 1
  rescue e
    puts e.backtrace.join("\n"), e
    exit 1
  end

  # :nodoc:
  def self.process_tasks(args)
    while (definition = read_task(args))
      invoke(*definition)
    end
  end

  private def self.read_task(args : Array(String))
    return if args.empty?

    args.shift if args[0] == TASK_SEPARATOR
    task = args.shift
    task_args = args.take_while { |argument| argument != TASK_SEPARATOR }
    args.shift(task_args.size)
    {task, task_args}
  end
end
