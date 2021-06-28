require "./spec_helper"

describe Sam::ShellTable do
  describe "#generate" do
    it "generates correct table" do
      fail "terminal should has width 80" if `tput cols`.to_i != 80

      namespace = Sam::Namespace.new("name", nil)
      Sam::ShellTable.new([
        Sam::Task.new(
          ->{},
          %w[],
          namespace,
          "short_name",
          "but very long description, such long that it requires multiple lines to be written"
        ),
        Sam::Task.new(
          ->{},
          %w[],
          namespace,
          "very_long_task_name_such_long_that_it_requires_multiple_lines_to_be_written",
          "and short description"
        ),
      ]).generate.should eq(
        <<-TEXT
        Name                                     Description
        -------------------------------------- | ---------------------------------------
        short_name                             | but very long description, such long th
                                               | at it requires multiple lines to be wri
                                               | tten
        very_long_task_name_such_long_that_it_ | and short description
        requires_multiple_lines_to_be_written  |                                        \n
        TEXT
      )
    end
  end
end
