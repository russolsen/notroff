class CodeTypeRefiner
  def process( paragraphs )
    processed_paragraphs = []

    previous_type = nil

    paragraphs.each_with_index do |paragraph, i|
      type = paragraph[:type]
      previous_type = previous_paragraph_type(paragraphs, i)
      next_type = next_paragraph_type(paragraphs, i)
      new_type = code_type_for( previous_type, type, next_type )
      new_paragraph = paragraph.clone
      new_paragraph[:type] = new_type
      processed_paragraphs << new_paragraph
    end
    processed_paragraphs
  end

  def previous_paragraph_type(paragraphs, i)
    return nil if i <= 0
    paragraphs[i-1][:type]
  end

  def next_paragraph_type(paragraphs, i)
    return nil if (i + 1) >= paragraphs.size
    paragraphs[i+1][:type]
  end

  def code_type_for( previous_type, type, next_type )
    Logger.log "code type for [#{previous_type}] [#{type}] [#{next_type}]"
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

    Logger.log("new type: #{new_type}")
    new_type
  end
end
