require "./makefile"
require "./shell_table"

desc "Prints description for all tasks"
task "help" do
  puts Sam::ShellTable.new(Sam.root_namespace.all_tasks).generate
end

namespace "generate" do
  desc "Generates makefile extension. Now command could be executed via `make sam your:command argument`"
  task "makefile" do |_, args|
    sam_file_path = args.raw.size == 1 ? args.raw[0].as(String) : "src/sam.cr"
    Sam::Makefile.new(sam_file_path).generate
  end
end
