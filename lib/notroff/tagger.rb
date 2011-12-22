require 'stringio'

class TagDirectiveExtractor
  def process( paragraphs )
    paragraphs.each do |p|
      text = p.text
      if contains_directives?(p.text)
        tag_text = p.text.sub(/^.*##/, '')
        p.text = p.text.sub(/##.*$/, '')
        directives = extract_tag_directives(tag_text)
        p.add_directive(*directives)
      end
    end
    paragraphs
  end

  def contains_directives?(text)
    /##[a-z_+\-()! ]*$/ =~ text
  end

  def extract_tag_directives(text)
    tags = text.scan(/\([a-z]+|[a-z]+\)|[+-][a-z]+|!/)
    tags.map do |raw|
      tag_name = raw.gsub(/[^a-z]/, '')
      case raw
      when /^\(/
        type = :start_range
      when /\)$/
        type = :end_range
      when /^\+/
        type = :include
      when /^-/
        type = :exclude
      when /^!/
        type = :exclude_all
      else
        raise "Dont know what to do with tag directive: #{raw}"
      end
      Directive.new(type, tag_name)
    end
  end
end

class Tagger
  def process( paragraphs )
    i = 0
    paragraphs.each do |p|
      apply_directives(paragraphs, i, p.directives)
      i += 1
    end
  end

  def apply_directives(paragraphs, index, directives)
    directives.each do |directive|
      apply_directive(paragraphs, index, directive)
    end
  end

  def apply_directive(paragraphs, index, directive)
    case directive.type
    when :start_range
      tag_range(paragraphs, index, directive.name)
    when :include
      paragraphs[index].tag(directive.name)
    when :exclude
      paragraphs[index].remove_tag(directive.name)
    when :exclude_all
      puts "Exclude all!!"
      paragraphs[index].tags.clear
    end
  end

  def tag_range(paragraphs, starting_index, tag_name)
    i = starting_index
    while i < paragraphs.size
      p = paragraphs[i]
      p.tag(tag_name)
      break if p.directive?(:end_range, tag_name)
      i += 1
    end
    raise "Did not find end for tag #{tag_name}" if i >= paragraphs.size
  end
end
