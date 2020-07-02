require "spec"
require "../src/sam"

load_dependencies "lib1"
load_dependencies "lib2": "special", "lib3": ["/special"]

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

# Callbacks

Spec.before_each do
  Container.clear
  Sam.root_namespace.all_tasks.each(&.reenable)
end

# Tasks

namespace "db" do
  namespace "schema" do
    task "load" do |t, args|
      puts args["f1"]
      t.invoke("1")
      t.invoke("schema:1")
      t.invoke("db:migrate")
      t.invoke("db:db:migrate")
      t.invoke("db:ping")
      t.invoke("din:dong")
      t.invoke("schema")
      Container.add(t.path)
    end

    task "1" do
      puts "1"
      Container.add("db:schema:1")
    end
  end

  task "with_argument" do |t, args|
    puts args["f1"]
    Container.add(t.path)
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
