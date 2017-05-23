require "spec"
require "../src/sam"

load_dependencies "asd"

Sam.namespace "db" do
  namespace "schema" do
    task "load" do |t, args|
      puts args["f1"]
      t.invoke("1")
      t.invoke("schema:1")
      t.invoke("db:migrate")
      t.invoke("db:db:migrate")
      t.invoke("db:ping")
      t.invoke("din:dong")
    end

    task "1" do
      puts "1"
    end
  end

  namespace "db" do
    task "migrate" do
      puts "migrate"
    end
  end

  task "ping" do
    puts "ping"
  end
end
