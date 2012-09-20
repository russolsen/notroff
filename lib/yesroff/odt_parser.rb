require 'rexml/document'
require 'pp'
require 'zip/zipfilesystem'

DEBUG=true

def log(*args)
  $stderr.puts args.join(' ')
end

def debug(*args)
  #return unless DEBUG
  puts args.join(' ')
end
 
def additional_styles(styles)
  log "noop additional paragraph styles function"
end

debug additional_text_styles(styles)
  log "noop additional text styles function"
end

class OdtParser
  def initialize(odt_path)
    if File.exist?("yesroff.rc")
      log "loading notroff.rb"
      load 'yesroff.rc'
    end

    log "Reading #{odt_path}..."
    Zip::ZipFile.open(odt_path ) do |zipfile|
      zipfile.file.open("content.xml") do |content|
        @doc = REXML::Document.new(content.read)
      end
    end
    log "Done"

    @writer = NRWriter.new
    @paras = []
    @text_styles = default_text_styles
    @para_styles = default_para_styles
  end

  def default_text_styles
    cd1 = TextStyle.new("CD1")
    cd1.code = true

    hash = StyleHash.new
    hash.add_style cd1
    hash.add_style TextStyle.new("Default")
    hash.add_style TextStyle.new("C1")
    hash.add_style TextStyle.new("C1_20_HD")
    hash.add_style TextStyle.new("FN")
    hash.add_style TextStyle.new("Base_20_Font")
    hash.add_style TextStyle.new("Chapter_20_Word")
    additional_text_styles(hash)
    hash
  end


  def default_para_styles
    styles = StyleHash.new
    styles.add_style ParagraphStyle.new('FT', nil, :body, false)
    styles.add_style ParagraphStyle.new('IT', nil, :body, false)
    styles.add_style ParagraphStyle.new('Quotation', nil, :quote, true)

    styles.add_style ParagraphStyle.new('CDT1', nil, :code, false)
    styles.add_style ParagraphStyle.new('CDT', nil, :code, false)
    styles.add_style ParagraphStyle.new('CDTX', nil, :code, false)
    styles.add_style ParagraphStyle.new('C1', nil, :c1, true)
    styles.add_style ParagraphStyle.new('C2', nil, :c1, true)
    styles.add_style ParagraphStyle.new('TB', nil, :c1, true)
    styles.add_style ParagraphStyle.new('Free_20_Form', nil, :c1, true)


    styles.add_style ParagraphStyle.new('NLC1', nil, :code, false)
    styles.add_style ParagraphStyle.new('NLC', nil, :code, false)
    styles.add_style ParagraphStyle.new('NLCX', nil, :code, false)
    styles.add_style ParagraphStyle.new('NLPara', nil, :code, false)

    styles.add_style ParagraphStyle.new('TX', nil, :code, false)

    styles.add_style ParagraphStyle.new('HA', nil, :title, true)
    styles.add_style ParagraphStyle.new('HB', nil, :subtitle, true)
    styles.add_style ParagraphStyle.new('HC', nil, :sec, true)
    styles.add_style ParagraphStyle.new('HD', nil, :subsec, true)
    styles.add_style ParagraphStyle.new('TH', nil, :theading, true)
    styles.add_style ParagraphStyle.new('LH', nil, :ltitle, true)
    styles.add_style ParagraphStyle.new('LC', nil, :listing, false)
    styles.add_style ParagraphStyle.new('LC2', nil, :listing, false)
    styles.add_style ParagraphStyle.new('LX', nil, :listing, false)

    styles.add_style ParagraphStyle.new('BL1', nil, :bullet, true)
    styles.add_style ParagraphStyle.new('BL', nil, :bullet, true)
    styles.add_style ParagraphStyle.new('BX', nil, :bullet, true)

    styles.add_style ParagraphStyle.new('NL1', nil, :list, true)
    styles.add_style ParagraphStyle.new('NL', nil, :list, true)
    styles.add_style ParagraphStyle.new('NX', nil, :list, true)

    styles.add_style ParagraphStyle.new('BL Para', nil, :bullet, true)
    styles.add_style ParagraphStyle.new('Quotation_20_Attribution', nil, :attribution, true)

    additional_paragraph_styles(styles)
    styles
  end

  def parse
    parse_text_styles
    parse_paragraph_styles
    @paras = parse_paragraphs
  end

  def render
    @paras.each {|p| p.render(@writer)}
  end

  def parse_text_styles
    log "Parsing text styles"
    styles = REXML::XPath.match(@doc, "//style:style[@style:family='text']")
    styles.each do |s|
      attrs = s.attributes
      style = TextStyle.new(attrs['style:name'])
      props = REXML::XPath.first(s, "./style:text-properties")
      if props
        style.bold = (props.attributes['fo:font-weight'] == 'bold')
        style.italic = (/italic/i =~ props.attributes['style:font-name']) ||
          (props.attributes['fo:font-style'] == 'italic')
      end
      @text_styles[style.name] = style
    end
  end

  def parse_paragraph_styles
    log "Parsing paragraph styles"
    styles = REXML::XPath.match(@doc, "//style:style[@style:family='paragraph']")
    styles.each do |s|
      attrs = s.attributes
      style = ParagraphStyle.new(attrs['style:name'])
      style.parent = find_or_create_para_style(attrs['parent-style-name'])
      @para_styles[style.name] = style
    end
  end

  def parse_paragraphs
    log "Parsing paragraphs"
    results = []
    paras = REXML::XPath.match(@doc, '//text:p')
    paras.each do |p|
      results << parse_paragraph(p)
    end
    results
  end

  def lookup_para_style(name)
    s = @para_styles[name]
    log "No such para style #{name}" unless s
    raise "No such para style #{name}" unless s
    s
  end

  def find_or_create_para_style(name)
    return lookup_para_style(name)
    s = @para_styles[name]
    unless s
      STDERR.puts "Warning: no paragraph style named #{name}"
      s = ParagraphStyle.new(name, nil, :body, false)
      @para_styles[s.name] = s
      s
    end
  end

  def lookup_text_style(name)
    name = "Default" if name.nil? or name.empty?
    s = @text_styles[name]
    raise "No such text style [[#{name}]]" unless s
    s
  end

  def find_or_create_text_style(name)
    s = @text_styles[name]
    unless s
      STDERR.puts "Warning: no character style named #{name}"
      s = TextStyle.new(name)
      @text_styles[s.name] = s
    end
    s
  end

  def parse_paragraph(p)
    attrs = p.attributes
#    puts "Parsing paragraph, attrs #{attrs}"
#    puts "==> style-name: [[#{attrs['text:style-name']}]]"
    style = find_or_create_para_style(attrs['text:style-name'])

    para = Paragraph.new(style)
    para.contents = parse_contents(para, p)
    para
  end

  def parse_indent(el)
  end

  def parse_span(el)
    attrs = el.attributes
    indent = attrs['text:c'] ? attrs['text:c'].to_i : 0
    style = find_or_create_text_style(attrs['text:style-name'])
    span = Span.new(style)
    span.indent = indent
    span.contents = parse_contents(span, el)
    log("new span: #{span}")
    span
  end

  def parse_contents(contents, el)
    results = []
    el.each_child do |kid|
      if REXML::Text === kid
        results << Text.new(REXML::Text.unnormalize(kid.value))
      else
        results << parse_span(kid)
      end
    end
    results
  end
end
