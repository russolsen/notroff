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
 
class OdtParser

  def initialize(odt_path)
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

    styles = [
      cd1,
      TextStyle.new("Default"),
      TextStyle.new("C1"),
      TextStyle.new("C1_20_HD"),
      TextStyle.new("FN"),
      TextStyle.new("Base_20_Font"),
      TextStyle.new("Chapter_20_Word")
    ]
    hash = {}
    styles.each {|s| hash[s.name] = s}
    hash
  end

  def default_para_styles
    styles = [
    ParagraphStyle.new('FT', nil, :body, false),
    ParagraphStyle.new('IT', nil, :body, false),
    ParagraphStyle.new('Quotation', nil, :quote, true),

    ParagraphStyle.new('CDT1', nil, :code, false),
    ParagraphStyle.new('CDT', nil, :code, false),
    ParagraphStyle.new('CDTX', nil, :code, false),
    ParagraphStyle.new('C1', nil, :c1, true),
    ParagraphStyle.new('C2', nil, :c1, true),
    ParagraphStyle.new('TB', nil, :c1, true),
    ParagraphStyle.new('Free_20_Form', nil, :c1, true),


    ParagraphStyle.new('NLC1', nil, :code, false),
    ParagraphStyle.new('NLC', nil, :code, false),
    ParagraphStyle.new('NLCX', nil, :code, false),
    ParagraphStyle.new('NLPara', nil, :code, false),

    ParagraphStyle.new('TX', nil, :code, false),

    ParagraphStyle.new('HA', nil, :title, true),
    ParagraphStyle.new('HB', nil, :subtitle, true),
    ParagraphStyle.new('HC', nil, :sec, true),
    ParagraphStyle.new('HD', nil, :subsec, true),
    ParagraphStyle.new('TH', nil, :theading, true),
    ParagraphStyle.new('LH', nil, :ltitle, true),
    ParagraphStyle.new('LC', nil, :listing, false),
    ParagraphStyle.new('LC2', nil, :listing, false),
    ParagraphStyle.new('LX', nil, :listing, false),

    ParagraphStyle.new('BL1', nil, :bullet, true),
    ParagraphStyle.new('BL', nil, :bullet, true),
    ParagraphStyle.new('BX', nil, :bullet, true),

    ParagraphStyle.new('NL1', nil, :list, true),
    ParagraphStyle.new('NL', nil, :list, true),
    ParagraphStyle.new('NX', nil, :list, true),

    ParagraphStyle.new('BLPara', nil, :bullet, true),
    ParagraphStyle.new('Quotation_20_Attribution', nil, :attribution, true)

    ]

    hash = {}
    styles.each {|s| hash[s.name] = s}
    hash
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
    #raise "No such para style #{name}" unless s
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

  def parse_span(el)
    attrs = el.attributes
    style = find_or_create_text_style(attrs['text:style-name'])
    indent = attrs['text:c'] ? attrs['text:c'].to_i : 0
    span = Span.new(style)
    span.indent = indent
    span.contents = parse_contents(span, el)
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
