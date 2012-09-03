class TypeAssigner
  def process( paragraphs )
    processed_paragraphs = []

    current_type = :body

    paragraphs.each do |paragraph|
      type = paragraph[:type]
      if (type == :body) or (type == :code) or (type == :listing)
        current_type = type
      elsif type == :quote
        paragraph[:type] = :quote
        processed_paragraphs << paragraph
      elsif type == :c1 || type == :code1
        paragraph[:type] = :code
        processed_paragraphs << paragraph
      elsif type == :text
        paragraph[:type] = current_type
        processed_paragraphs << paragraph
      else
        processed_paragraphs << paragraph
      end

      current_type = :body if [ :section, :sec, :c1, :subsec, :title, :code1 ].include?(type)
    end
    processed_paragraphs
  end
end
