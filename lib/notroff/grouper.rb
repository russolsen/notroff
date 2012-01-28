class Grouper
  def initialize(type)
    @type = type
  end


  def process( paragraphs )
    processed = []
    kids = nil
    paragraphs.each do |para|
      if para[:type] == @type
        kids ||= []
        kids << para
      else
        processed << new_group_paragraph(@type, kids) if kids
        kids = nil
        processed << para
      end
    end
    processed << new_group_paragraph(@type, kids) if kids
    processed
  end

  def new_group_paragraph(kid_type, kids)
    group_paragraph = Text.new('.group')
    group_paragraph[:kids] = kids
    group_paragraph[:type] = :group
    group_paragraph[:kid_type] = kid_type
    group_paragraph
  end
end

class Ungrouper
  def initialize(type)
    @type = type
  end

  def process( paragraphs )
    processed = []

    paragraphs.each do |para|
      if para[:type] != :group
        processed << para
      elsif para[:kid_type] != @type
        processed << para
      else
        kids = expand_group(para[:kids])
        processed.add_all(kids) if kids
      end
    end
  end

  def expand_group(group)
    group
  end
end

class FirstMiddleLastUngrouper
  def initialize(starting, first, middle, last, single = middle)
    super(starting)
    @first_type = first
    @middle_type = middle
    @last_type = last
    @single_type = single
  end

  def expand_group(group)
    group.each_with_index do |item, i|
      if group.size == 1
        item[:type] = @single_type
      elsif i == 0
        item[:type] = @first_type
      elsif i == group.size-1
        item[:type] = @last_type
      else
        item[:type] = @middle_type
      end
    end
  end
end
