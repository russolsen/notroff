class TypeAssigner
  def process( paragraphs )
    processed_paragraphs = []

    current_type = :body

    paragraphs.each do |paragraph|
      type = paragraph[:type]
      if (type == :body) or (type == :code) or (type == :quote)
        current_type = type
      elsif type == :code1
        paragraph[:type] = :code
        processed_paragraphs << paragraph
      elsif type == :text
        paragraph[:type] = current_type
        processed_paragraphs << paragraph
      else
        processed_paragraphs << paragraph
      end

      current_type = :body if [ :section, :title, :code1 ].include?(type)
    end
    processed_paragraphs
  end
end
