require 'stringio'

# filter :tag foo
# code
# code
# code
# end_filter :tag foo
class NewTagFilter
  def process( paragraphs )
    filter_tag = nil
    new_paragraphs = []

    paragraphs.each do |p|
      if p.type == :filter
        filter_tag = p.tag_value(:filter_tag)
      elsif p.type == :end_filter and p.tag_value(:filter_tag) == filter_tag
        filter_tag = nil
      elsif filter_tag == nil
        new_paragraphs << p
      elsif p.tagged?(filter_tag)
        new_paragraphs << p
      else
        puts "Skipping #{p.text}, not tagged with #{filter_tag}"
      end
    end
    new_paragraphs
  end
end
