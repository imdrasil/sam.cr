require "./task"

module Sam
  # :nodoc:
  class ShellTable
    BORDER = " | "

    getter tasks : Array(Task), width : Int32

    def initialize(@tasks)
      @width = terminal_width
    end

    def generate
      String.build do |io|
        write_header(io)
        tasks.each { |task| write_task(io, task) }
      end
    end

    private def terminal_width
      if has_tput?
        `tput cols`.to_i
      elsif has_stty?
        `stty size`.chomp.split(' ')[1].to_i
      else
        80
      end
    end

    private def has_tput?
      !`which tput`.empty?
    end

    private def has_stty?
      return false if `which stty`.empty?

      /\d* \d*/.matches?(`stty size`)
    end

    private def write_header(io)
      io << "Name".ljust(name_column_width) << "   Description\n"
      io << "-" * name_column_width << BORDER << "-" * description_column_width << "\n"
    end

    private def write_task(io, task)
      name = task.path
      description = task.description
      while !(name.empty? && description.empty?)
        if !name.empty?
          segment_length = [name.size, name_column_width].min
          io << name[0...segment_length].ljust(name_column_width)

          name = name.size == segment_length ? "" : name[segment_length..-1]
        else
          io << " " * name_column_width
        end
        io << BORDER

        if !description.empty?
          segment_length = [description.size, description_column_width].min
          io << description[0...segment_length]
          description = description.size == segment_length ? "" : description[segment_length..-1]
        else
          io << " " * description_column_width
        end
        io << "\n"
      end
    end

    private def name_column_width
      @name_column_width ||=
        [
          [
            tasks.map(&.path.size).max,
            clean_width * min_content_width_ratio,
          ].max,
          clean_width * max_content_width_ration,
        ].min.to_i.as(Int32)
    end

    private def description_column_width
      @description_column_width ||= (clean_width - name_column_width).as(Int32)
    end

    private def max_content_width_ration
      0.5
    end

    private def min_content_width_ratio
      0.1
    end

    private def clean_width
      width - 3
    end
  end
end
