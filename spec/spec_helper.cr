require "spec"
require "../src/sam"

load_dependencies "lib1"
load_dependencies "lib2": "special", "lib3": ["/special"]

# Helpers

class Container
  @@executed_tasks = [] of String

  def self.add(name)
    @@executed_tasks << name
  end

  def self.tasks
    @@executed_tasks
  end

  def self.clear
    @@executed_tasks.clear
  end
end

def execute(command, options)
  io = IO::Memory.new

  status =
    {% if flag?(:win32) %}
      Process.run("#{command} \"${@}\"", options, output: io, error: io)
    {% else %}
      Process.run("#{command} \"${@}\"", options, shell: true, output: io, error: io)
    {% end %}.exit_status
  {status, io.to_s}
end

# Callbacks

Spec.before_each do
  Container.clear
  Sam.root_namespace.all_tasks.each(&.reenable)
end

# Tasks

namespace "db" do
  namespace "schema" do
    task "load" do |task, args|
      puts args["f1"]
      task.invoke("1")
      task.invoke("schema:1")
      task.invoke("db:migrate")
      task.invoke("db:db:migrate")
      task.invoke("db:ping")
      task.invoke("din:dong")
      task.invoke("schema")
      Container.add(task.path)
    end

    task "1" do
      puts "1"
      Container.add("db:schema:1")
    end
  end

  task "with_argument" do |task, args|
    puts args["f1"]
    Container.add(task.path)
  end

  task "schema" do
    puts "same as namespace"
    Container.add("db:schema")
  end

  namespace "db" do
    task "migrate" do
      puts "migrate"
      Container.add("db:db:migrate")
    end
  end

  task "ping" do
    puts "ping"
    Container.add("db:ping")
  end
end
