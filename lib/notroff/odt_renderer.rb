require 'rexml/document'
require 'pp'


class OdtRenderer < Processor
  include Tokenize
  include REXML

  LONG_DASH_CODE = 0xe1.chr + 0x80.chr + 0x93.chr

  PARAGRAPH_STYLES = { 
    :body => 'FT',
    :body2 => 'IT',
    :title => 'HA',
    :subtitle => 'HB',
    :section => 'HC',
    :sec => 'HC',
    :subsec => 'HD',
    :first_code => 'CDT1',
    :middle_code => 'CDT',
    :end_code => 'CDTX',
    :author => 'AU',
    :quote => 'Quotation',
    :attribution => 'Quotation Attribution',
    :single_code => 'C1',
    :ltitle => 'LH',
    :first_listing => 'LC',
    :middle_listing => 'LC2',
    :end_listing => 'LX',
    :pn => 'PN',
    :pt => 'PT',
    :cn => 'HA',
    :chapter => 'HA',
    :ct => 'HB',
    :fc => 'FC'}

  @@footnote_number = 1

  def process( paragraphs )
    elements = []
    paragraphs.each do |paragraph|
      new_element = format( paragraph )
      elements << new_element if new_element
    end
    {:body => elements}
  end

  def format( para )
    Logger.log "Format: #{para.inspect}"
    type = para[:type]
    text = para

    return nil if text.empty? and ! code_type?( type )

    result = nil


    if [:body, :body2].include?(type)
      Logger.log("Rendering bodyish para of type ", type )
      result = new_text_element( type )
      add_body_text( text, result )

    elsif quote_type?(para)
      result = new_quote_element(para[:kid_type], para[:kids])

    elsif list_type?(para)
      result = new_list_element(para[:kids])

    elsif bullet_type?(para)
      result = new_bullet_element(para[:kids])

    elsif code_type?(type)
      result = new_text_element( type )
      add_code_text( text, result )

    elsif PARAGRAPH_STYLES[type]
      Logger.log("Rendering simple para of type ", type )
      result = new_text_element( type )
      result.add_text( text.string )

    else
      raise "Dont know what to do with type [#{type}]"
    end
    result
  end

  def group?(para)
    para[:type] == :group
  end

  def quote_type?(para)
    group?(para) and [:quote, :attribution].include?(para[:kid_type])
  end

  def list_type?(para)
    group?(para) and para[:kid_type] == :list
  end

  def bullet_type?(para)
    group?(para) and para[:kid_type] == :bullet
  end

  def code_type?( type )
    [ :first_code, :middle_code, :end_code, :single_code,
      :listing, :first_listing, :middle_listing, :end_listing ].include?(type)
  end

  def new_quote_element(type, items)
    p = new_text_element(type)
    items.each_with_index do |item, i|
      p.add( Element.new('text:line-break')) unless i == 0
      el = Element.new('text:span')
      add_body_text(item.string, el)
      p.add(el)
    end
    p
  end

  def new_list_element(items)
    list = Element.new('text:list')
    list.attributes['text:style-name'] = 'L2'
    items.each_with_index do |item, i|
      list_item_element = Element.new('text:list-item')
      text_element = Element.new('text:p')
      text_element.attributes['text:style-name'] = numbered_item_style_for(items, i)
      add_body_text(item.string, text_element)
      list_item_element.add(text_element)
      list.add(list_item_element)
    end
    list
  end

  def numbered_item_style_for(items, i)
    return 'P7' if i == 0
    return 'P4' if i == (items.size-1)
    'P3'
  end

  def new_bullet_element(items)
    list = Element.new('text:list')
    list.attributes['text:style-name'] = 'L1'
    items.each_with_index do |item, i|
      list_item_element = Element.new('text:list-item')
      text_element = Element.new('text:p')
      text_element.attributes['text:style-name'] = bullet_item_style_for(items, i)
      add_body_text(item.string, text_element)
      list_item_element.add(text_element)
      list.add(list_item_element)
    end
    list
  end

  def bullet_item_style_for(items, i)
    return 'List_20_1_20_Start' if i == 0
    return 'List_20_1_20_End' if i == (items.size-1)
    'List_20_1_20_Cont.'
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

  def add_code_text( text, element )
    text = text.dup
    re = /\S+|\s+/
    until text.empty?
      chunk = text.slice!( re )
      if chunk !~ /^ /
        element.add_text( chunk.string )
      else
        space_element = Element.new( 'text:s' )
        space_element.attributes['text:c'] = chunk.size.to_s
        element.add( space_element )
      end
    end
  end

  def add_span( token, element )
    case token[:type]
    when :italic
      element.add( span_for( token.string, "T1" ))
    when :code
      element.add( span_for( token.string, "CD1" ))
    when :bold
      element.add( span_for( token.string, "T2" ))
    when :normal
      element.add_text( token.string )
    when :footnote
      element.add( footnote_for( token.string ) )
    when :link
      text, url = parse_link(token)
      add_body_text(text, element)
      element.add_text( " (#{url}) " )
    else
      raise "Dont know what to do with #{token}"
    end
  end

  def span_for( text, style )
    span = Element.new( "text:span" )
    span.attributes['text:style-name'] = style
    span.text = remove_escapes(text)
    span
  end

  def remove_escapes( text )
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
    add_body_text(text, note_paragraph)

    note_body.add( note_paragraph )
    note_element.add( note_body )
    @@footnote_number += 1
    note_element
  end
end
