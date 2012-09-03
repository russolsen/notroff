class TypeRefiner
  def process( paragraphs )
    processed_paragraphs = []

    previous_type = nil

    paragraphs.each_with_index do |paragraph, i|
      type = paragraph[:type]
      previous_type = previous_paragraph_type(paragraphs, i)
      next_type = next_paragraph_type(paragraphs, i)
      new_type = type_for( previous_type, type, next_type )
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
end

class CodeTypeRefiner < TypeRefiner
  def initialize(base_type=:code, first_type=:first_code, middle_type=:middle_code,
    end_type=:end_code, single_type=middle_type)
    @base_type = base_type
    @first_type = first_type
    @middle_type = middle_type
    @end_type = end_type
    @single_type = single_type
  end

  def type_for( previous_type, type, next_type )
    Logger.log "code type for [#{previous_type}] [#{type}] [#{next_type}]"
    if type != @base_type
      new_type = type

    elsif previous_type ==@base_type and next_type == @base_type
      new_type = @middle_type

    elsif previous_type == @base_type
      new_type = @end_type

    elsif next_type == @base_type
      new_type = @first_type

    else
      new_type = @single_type
    end

    Logger.log("new type: #{new_type}")
    new_type
  end
end

class BodyTypeRefiner < TypeRefiner
  def type_for( previous_type, type, next_type )
    Logger.log "body type for [#{previous_type}] [#{type}] [#{next_type}]"

    new_type = type
    if (type == :body) and (previous_type == :body)
      new_type = :body2
    end

    Logger.log("new type: #{new_type}")
    new_type
  end
end
