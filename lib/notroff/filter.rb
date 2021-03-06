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

class RegularExpressionExcludeFilter < Filter
  def initialize(exclude_re)
    @exclude_re = exclude_re
  end

  def included?(paragraph)
    @exclude_re !~ paragraph    
  end
  
end
