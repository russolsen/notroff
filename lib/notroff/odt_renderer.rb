require 'rexml/document'
require 'pp'


class OdtRenderer < Processor

  include REXML

  PARAGRAPH_STYLES = { 
    :body => 'BodyNoIndent', :title => 'HB', :section => 'HC', :sec => 'HC',
    :first_code => 'CDT1', :middle_code => 'CDT', :end_code => 'CDTX',
    :single_code => 'C1', :pn => 'PN', :pt => 'PT', :cn => 'HA', :ct => 'HB' }

  @@footnote_number = 1

  def process( paragraphs )
pp paragraphs
    elements = []
    paragraphs.each do |paragraph|
      new_element = format( paragraph )
      elements << new_element if new_element
    end
    #puts elements.join("\n")
    elements
  end

  def format( p )
    type = p.type
    text = p.text

    return nil if text.empty? and ! code_type?( type )

    result = new_text_element( type )

    if [ :section, :sec, :title, :pn, :pt, :cn, :ct ].include?( type )
      result.add_text( text )
    elsif type == :body
      add_body_text( text, result )
    elsif code_type?(type)
      add_code_text( text, result )
    else
      raise "Dont know what to do with type [#{type}]"
    end
    result
  end

  def code_type?( type )
    [ :first_code, :middle_code, :end_code, :single_code ].include?(type)
  end

  def new_text_element( type )
    result = Element.new( "text:p" )
    result.attributes["text:style-name"] = PARAGRAPH_STYLES[type]
    result
  end

  def add_body_text( text, element )
    tokens = tokenize_body_text( text )
    tokens.each {|token| add_span( token, element ) }
  end

  def tokenize_body_text( text )
    text = text.dup
    re = /\~\~.*?\~\~|\@\@.*?\@\@+|\{\{.*?\}\}|!!.*?!!/
    results = []
    until text.empty?
      match = re.match( text )
      if match.nil?
        results << { :type => :normal, :text => text }
        text = ''
      else
        unless match.pre_match.empty?
          results << { :type => :normal, :text => match.pre_match }
        end
        token =  match.to_s
        results << { :type => token_type(token), :text => token_text(token) }
        text = match.post_match
      end
    end
    results
  end

  def token_type( token )
    case token
    when /^\~/
      :italic
    when /^\@/
      :code
    when /^\{/
      :footnote
    when /^!/
      :bold
    end 
  end

  def token_text( token )
    result = token.sub( /^../, '' ).sub( /..$/, '')
    #print "token text for #{token} [[#{result}]]"
    result
  end

  def add_code_text( text, element )
    #element.add_text( text )
#puts "### adding code for [[#{text}]]"

    text = text.dup
    re = /\S+|\s+/
    until text.empty?
      chunk = text.slice!( re )
#puts "### chunk: #{chunk}"
      if chunk !~ /^ /
        element.add_text( chunk )
      else
        space_element = Element.new( 'text:s' )
        space_element.attributes['text:c'] = chunk.size.to_s
#puts "####adding space element for #{chunk.size}: #{space_element}"
        element.add( space_element )
      end
    end
  end

  def add_span( token, element )
    case token[:type]
    when :italic
      element.add( span_for( token[:text], "T1" ))
    when :code
      element.add( span_for( token[:text], "CD1" ))
    when :bold
      element.add( span_for( token[:text], "T2" ))
    when :normal
      element.add_text( token[:text] )
    when :footnote
      element.add( footnote_for( token[:text] ) )
    else
      raise "Dont know what to do with #{token}"
    end
  end

  def span_for( text, style )
    span = Element.new( "text:span" )
    span.attributes['text:style-name'] = style
    #span.text = process_text( text )
    span.text = remove_escapes(text)
    span
  end

  def remove_escapes( text )
print "remove escapes, [#{text}] => "
    text = text.clone

    results = ''

    until text.empty?
      match = /\\(.)/.match( text )
      if match.nil?
        results << text
        text = ''
      else
        unless match.pre_match.empty?
          results << match.pre_match
        end
        results << match[1]
        text = match.post_match
      end
    end
#puts " #{results}"
    results
  end

  def footnote_for(text )
    note_element = Element.new( "text:note" )
    note_element.attributes["text:id"] ="ftn#{@@footnote_number}"
    note_element.attributes["text:note-class"] ="footnote"
    
    cit = Element.new( "text:note-citation" )
    cit.add_text( "#{@@footnote_number}" )
    note_element.add( cit )

    note_body = Element.new( "text:note-body" )
    note_paragraph = Element.new( "text:p" )
    note_paragraph.attributes['text:style-name'] = 'FTN'
    note_paragraph.add_text( text )

    note_body.add( note_paragraph )
    note_element.add( note_body )
    @@footnote_number += 1
    note_element
  end

end

