class CommandProcessor
  def process( lines )
    paragraphs = []
    lines.each do |line|
      cmd, text = parse_line( line )
      if cmd.empty?
        cmd = :text
      else
        cmd = cmd.sub(/^./, '').to_sym
      end
      para = Text.new(text, :type => cmd, :original_text => line.to_s)
      paragraphs << para
    end
    paragraphs
  end

  def parse_line( line )
    match_data = /^(\.\w+ ?)(.*)/.match(line)
    if match_data
      cmd = match_data[1].strip
      text = match_data[2]
    else
      cmd = ''
      text = line
    end
    [ cmd.strip, text ]
  end
end
