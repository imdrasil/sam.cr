require "./sam/*"

module Sam
  @@root_namespace = Namespace.new("root", nil)

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

  def self.invoke(name)
    invoke(name, Args.new)
  end

  def self.invoke(name, args : Args)
    t = find(name)
    if t
      t.not_nil!.call(args)
    else
      raise "Task #{name} was not found"
    end
  end

  def self.invoke(name, args : Array(String))
    t = find(name)
    if t
      t.not_nil!.call(Args.new(args))
    else
      raise "Task #{name} was not found"
    end
  end

  def self.find(path)
    @@root_namespace.find(path)
  end

  def self.find!(path)
    @@root_namespace.find(path).not_nil!
  end

  def self.help
    if ARGV.size > 0
      Sam.invoke(ARGV[0], ARGV[1..-1])
    else
      puts "Hm, nothing to do"
    end
  rescue e
    puts e.backtrace.join("\n")
    puts e
    exit(1)
  end

  def self.pretty_print
    descs = [] of String
    tasks = @@root_namespace.all_tasks
    pathes = tasks.map(&.path)
    max_length = pathes.map(&.size).max
    puts "Tasks:"
    puts "-" * (max_length + 2) + ":" + "-" * 20
    tasks.each_with_index do |task, i|
      puts pathes[i].ljust(max_length + 5) + task.description
    end
  end
end

macro load_dependencies(*libraries)
  {% for l in libraries %}
    require "{{l.id}}/sam"
  {% end %}
end

macro load_dependencies(home_path, *libraries)
  {% for l in libraries %}
    require "{{home_path.id}}/lib/{{l.id}}/src/sam"
  {% end %}
end

Sam.desc("Prints description for all tasks")
Sam.task "help" do
  Sam.pretty_print
end
