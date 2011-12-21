require 'rexml/document'
require 'pp'

class HtmlRenderer < Processor
  include Tokenize
  include REXML

  def process( paragraphs )
    body = Element.new('body')
    paragraphs.each do |paragraph|
      new_element = format( paragraph )
      body.add new_element if new_element
    end
    puts body.to_s
    body
  end

  def format( p )
    type = p.type
    text = p.text

    return nil if text.empty? and :type != :code

    #puts "type: #{type}"
    if type == :code
      code_element(type, text)
    else
      text_element(type, text)
    end
  end

  def text_element(type, text)
    element = Element.new(tag_for(type))
    add_body_text(text, element)
    element
  end

  def tag_for(type)
    case type
    when :body
      'p'
    when :text
      'p'
    when :author
      'h3'
    when :sec
      'h3'
    when :title
      'h2'
    else
        raise "Dont know what to do with #{type}"
    end
  end

  def add_body_text( text, element )
    tokens = tokenize_body_text( text )
    tokens.each {|token| add_span( token, element ) }
  end

  def add_span( token, element )
    case token[:type]
    when :italic
      element.add( span_for( token[:text], "em" ))
    when :code
      element.add( span_for( token[:text], "code" ))
    when :bold
      element.add( span_for( token[:text], "b" ))
    when :normal
      element.add_text( token[:text] )
    else
      raise "Dont know what to do with #{token}"
    end
  end

  def code_element(type, text)
    element = Element.new('code')
    pre_element = Element.new('pre')
    element.add pre_element
    pre_element.add_text text
    element
  end

  def span_for( text, style )
    span = Element.new( style )
    span.text = remove_escapes(text)
    span
  end
end

#p = [
#  Paragraph.new( :sec, "The section"),
#  Paragraph.new( :text, "hello @@some code@@ there\nhow ar you"),
#  Paragraph.new( :text, "hello @@some code@@ there\nhow ar you"),
#  Paragraph.new( :code, "if whatever\n  doit\nend"),
#  Paragraph.new( :text, "more text")
#]
#
#puts HTMLRenderer.new.process( p )
