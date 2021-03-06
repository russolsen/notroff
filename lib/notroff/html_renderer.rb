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
    body
  end

  def format( p )
    type = p[:type]
    text = p.string

    return nil if text.empty? and :type != :code

    if type == :code
      code_element(type, text)
    elsif type == :group and p[:kid_type] == :list
      list_element('ol', p[:kids])
    elsif type == :group and p[:kid_type] == :bullet
      list_element('ul', p[:kids])
    else
      text_element(type, text)
    end
  end

  def list_element(type, paras)
    list = Element.new(type)
    paras.each do |para|
      item = Element.new('li')
      add_body_text(para.string, item)
      list.add(item)
    end
    list
  end

  def text_element(type, text)
    puts "*** text element: #{type}"
    puts "*** text #{text}"
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
    when :section
      'h3'
    when :sec
      'h3'
    when :chapter
      'h2'
    when :quote
      'blockquote'
    when :title
      'h1'
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
      element.add(span_for(token.string, "em"))
    when :code
      element.add(span_for(token.string, "code"))
    when :bold
      element.add(span_for(token.string, "b"))
    when :normal
      element.add_text(token.string)
    when :footnote
      add_body_text(" [#{token.string}] ", element)
    when :link
      element.add(anchor_element_for(token))
    else
      raise "Dont know what to do with type #{token[:type]} - #{token}"
    end
  end

  def anchor_element_for(link_token)
    text, url = parse_link(link_token)
    anchor = Element.new('a')
    add_body_text(text, anchor)
    anchor.add_attribute('href', url)
    anchor
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
