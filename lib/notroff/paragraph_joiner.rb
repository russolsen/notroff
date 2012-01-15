class ParagraphJoiner
  def process( paragraphs )
    processed_paragraphs = []
    new_p = nil
    paragraphs.each do |paragraph|
      do_join = join?(paragraph)

      if join?(paragraph)
        if new_p
          new_p.string = join(new_p.string, paragraph)
        else
          new_p = paragraph
        end
      else
        if new_p
          processed_paragraphs << new_p
          new_p = nil
        end
        processed_paragraphs << paragraph unless skip?(paragraph)
      end
    end
    processed_paragraphs << new_p if new_p
    processed_paragraphs
  end

  def join(first, second)
    first + " " + second
  end

  def join?(paragraph)
    false
  end

  def skip?(paragraph)
    false
  end
end

class BodyParagraphJoiner < ParagraphJoiner
  def join?(paragraph)
    return false unless paragraph[:type] == :body
    return false if paragraph.empty?
    true
  end

  def skip?(paragraph)
    paragraph[:type] == :body && paragraph.empty?
  end
end

class CodeParagraphJoiner < ParagraphJoiner
  def join(first, second)
    first + "\n" + second
  end

  def join?(paragraph)
    return false unless paragraph[:type] == :code
    true
  end
end
