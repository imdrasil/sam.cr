desc "Prints description for all tasks"
task "help" do
  Sam.pretty_print
end

namespace "generate" do
  desc "Generates makefile extension. Now command could be executed via `make sam your:command argument`"
  task "makefile" do |t, args|
    sam_file_path = args.raw.size == 1 ? args.raw[0].as(String) : "src/sam.cr"
    Sam.generate_makefile(sam_file_path)
  end
end
