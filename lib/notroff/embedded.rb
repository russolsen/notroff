class EmbeddedRubyProcessor
  def initialize
  end
  def process(paragraphs)
    new_paragraphs = []
    paragraphs.each do |p|
      if p[:type] == :x
        puts p
        results = process_command(p.string)
        new_paragraphs << results if results
      else
        new_paragraphs << p
      end
    end
    new_paragraphs.flatten
  end

  def process_command(ruby_expression)
    puts "Ruby expression: #{ruby_expression}"
    lines = eval(ruby_expression, binding)
    lines.map {|p| Text.new(p, :type => :code)}
  end

  def inc(path)
    File.readlines(path).map {|line| line.rstrip}
  end

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
end
