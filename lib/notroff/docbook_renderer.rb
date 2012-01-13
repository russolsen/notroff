require 'rexml/document'
require 'pp'

class DocbookRenderer < Processor
  include Tokenize
  include REXML

  def process( paragraphs )
    @author = 'John Smith'
    @title = 'Wealth of Nations'
    @chapters = []
    @chapter = nil
    @section = nil

    paragraphs.each do |paragraph|
      format( paragraph )
    end
    @book = Element.new('book')
    @book.add_namespace('http://docbook.org/ns/docbook')
    @book.add_attribute('version', '5.0')
    @book.add_element element_for('title', @title)
    @book.add_element element_for('author', @author)
    @chapters.each {|ch| @book << ch}
    doc = Document.new
    decl = XMLDecl.new
    decl.version = '1.0'
    doc << decl
    doc << @book
    doc
  end

  def element_for(type, text)
    result = Element.new(type)
    result.add_text(text)
    result
  end

  def format( p )
    type = p[:type]
    text = p.string

    return nil if text.empty? and :type != :code

    case type
    when :title
      @title = text
    when :author
      @author = text
    when :chapter
      puts "adding chapter #{text}"
      @chapter = Element.new('chapter')
      @chapters << @chapter
      @section = nil
      title_element = Element.new('title')
      add_body_text(title_element, text)
      @chapter.add_element(title_element)
    when :section
      puts "adding section #{text}"
      @section = Element.new('section')
      @chapter.add(@section)
      title_element = Element.new('title')
      add_body_text(title_element, text)
      @section.add_element(title_element)
    when :body
      puts "adding body #{text[0..5]}"
      paragraph = Element.new('para')
      add_body_text(paragraph, text)
      add_content_element(paragraph)
    when :code
      add_content_element(code_element(type, text))
    else
      raise "#{type}???"
    end
  end

  def add_content_element(el)
    if @section
      @section.add_element(el)
    elsif @chapter
      @chapter.add_element(el)
    else
      raise "No chapter to add #{el} to"
    end
  end

  def text_element(type, text)
    element = [ tag_for(type) ]
    add_body_text(element, text)
    element
  end

  def tag_for(type)
    case type
    when :body
      'para'
    when :text
      'p'
    when :author
      'h3'
    when :section
      'h3'
    when :chapter
      'chapter'
    when :sec
      'h3'
    when :title
      'h2'
    else
        raise "Dont know what to do with #{type}"
    end
  end

  def add_body_text( element, text )
    tokens = tokenize_body_text( text )
    tokens.each {|token| add_span( token, element ) }
  end

  def add_span( token, element )
    puts "Add span: token: #{token} element: #{element}"
    case token[:type]
    when :italic
      element.add( span_for( token.string, "emphasis" ))
    when :code
      element.add( span_for( token.string, "code" ))
    when :bold
      element.add( span_for( token.string, "emphasis" ))
    when :normal
      element.add_text( token.string )
    when :footnote
      element.add(footnote_for(token.string))
    else
      raise "Dont know what to do with #{token}"
    end
  end

  def footnote_for( text )
    fn = Element.new('footnote')
    fn.add_element(element_for('para', text))
    fn
  end

  def code_element(type, text)
    element = Element.new('informalexample')
    prog_element = element_for('programlisting', text)
    prog_element.add_attribute('xml:space', 'preserve')
    element.add_element(prog_element)
    element
  end

  def span_for( text, style )
    span = Element.new(style)
    span.text = remove_escapes(text)
    span
  end
end
