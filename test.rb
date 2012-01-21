  def select(file, re1, re2)
    lines = File.readlines(file).map {|line| line.rstrip}
    filtered_lines = []
    state = :before_first
    lines.each do |line|
      if state == :before_first and re1 =~ line
        filtered_lines << line
        state = :after_first
      elsif state == :after_first
        filtered_lines << line
        break if line =~ re2
      end
    end
    filtered_lines
  end
