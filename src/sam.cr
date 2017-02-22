require "./sam/*"

module Sam
  @@root_namespace = Namespace.new("root", nil)

  def self.namespace(name : String)
    n = @@root_namespace.touch_namespace(name)
    with n yield
  end

  def self.task(name : String, deps = [] of String)
    @@root_namespace.task(name, deps)
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
  end
end

macro load_dependencies(libraries)
  load_dependencies("./", {{libraries}})
end

macro load_dependencies(home_path, *libraries)
  {% for l in libraries %}
    require "{{home_path.id}}lib/{{l.id}}/src/sam"
  {% end %}
end
