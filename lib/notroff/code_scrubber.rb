class CodeScrubber
  def process( paragraphs )
    paragraphs.each do |p|
      next unless p[:type] == :code
      p.string.gsub!(/##.*$/, '')
    end
    paragraphs
  end
end
