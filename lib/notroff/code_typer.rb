class CodeTypeRefiner
  def process( paragraphs )
    processed_paragraphs = []

    previous_type = nil

    paragraphs.each_with_index do |paragraph, i|
      type = paragraph[:type]
      previous_type = ( paragraphs.first == paragraph) ? nil : paragraphs[i-1][:type]
      next_type = ( paragraphs.last == paragraph) ? nil : paragraphs[i+1][:type]
      new_type = code_type_for( previous_type, type, next_type )
      paragraph[:type] = new_type
      processed_paragraphs << paragraph
    end
    processed_paragraphs
  end

  def code_type_for( previous_type, type, next_type )
    if type != :code
      new_type = type

    elsif previous_type == :code and next_type == :code
      new_type = :middle_code

    elsif previous_type == :code
      new_type = :end_code

    elsif next_type == :code
      new_type = :first_code

    else
      new_type = :single_code
    end

    new_type
  end
end
