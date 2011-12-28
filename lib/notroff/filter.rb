class Filter
  def process(paragraphs)
    paragraphs.find_all {|p| included?(p)}
  end

  def included?(paragraph)
    true
  end
end

class IncludedFilter < Filter
  def included?(paragraph)
    paragraph[:included]
  end
end
