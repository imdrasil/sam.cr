require "../src/sam"
require "file_utils"

class Container
  def self.add(a); end
end

Sam.task "setup" do
  lib1 = "./lib/lib1/src/lib1"
  lib2 = "./lib/lib2/src/lib2"
  lib3 = "./lib/lib3/src/lib3"
  sam_file1 = File.join(lib1, "sam.cr")
  next if File.exists?(sam_file1)

  # lib1

  FileUtils.mkdir_p(lib1)
  File.write(
    sam_file1,
    <<-DOC
    Sam.namespace "din" do
      task "dong" do
        puts "dong"
        Container.add("din:dong")
      end
    end
    DOC
  )

  # lib2

  FileUtils.mkdir_p(lib2)
  tasks_path = File.join(lib2, "tasks")
  FileUtils.mkdir_p(tasks_path)
  File.write(
    File.join(tasks_path, "special.cr"),
    <<-SAM
    Sam.namespace "lib2" do
      task "special" do |t|
        Container.add(t.path)
      end
    end
    SAM
  )
  File.write(
    File.join(lib2, "sam.cr"),
    <<-SAM
    Sam.namespace "lib2" do
      task "common" do |t|
        Container.add(t.path)
      end
    end
    SAM
  )

  # lib3

  FileUtils.mkdir_p(lib3)
  File.write(
    File.join(lib3, "sam.cr"),
    <<-SAM
    Sam.namespace "lib3" do
      task "common" do |t|
        Container.add(t.path)
      end
    end
    SAM
  )
  File.write(
    File.join(lib3, "special.cr"),
    <<-SAM
    Sam.namespace "lib3" do
      task "special" do |t|
        Container.add(t.path)
      end
    end
    SAM
  )
end

Sam.task "clear" do
  FileUtils.rm_r("./lib")
end

Sam.namespace "db" do
  namespace "schema" do
    desc "just test"
    task "load" do |t, args|
      puts args["f1"]
      t.invoke("1")
      t.invoke("schema:1")
      t.invoke("db:migrate")
      t.invoke("db:db:migrate")
      t.invoke("db:ping")
      t.invoke("din:dong")
      puts "------"
      t.invoke("2", {"f2" => 1})
    end

    desc "1"
    task "1" do
      puts "1"
    end

    task "2", ["1", "db:migrate"] do |_, args|
      puts args.named["f2"].as(Int32) + 3
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

Sam.help
