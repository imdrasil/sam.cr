require "../src/sam"
require "file_utils"

Sam.task "prepare" do
  path = "./lib/asd/src/asd"
  file = File.join(path, "sam.cr")
  next if File.exists?(file)
  FileUtils.mkdir_p(path)
  File.write(
    file,
    <<-DOC
      Sam.namespace "din" do
        task "dong" do
          puts "dong"
        end
      end
    DOC
  )
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

    task "2", ["1", "db:migrate"] do |t, args|
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
