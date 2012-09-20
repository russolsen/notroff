
class Style
  attr_accessor :name, :parent


  def initialize(name, parent = nil)
    @name = name
    @parent = parent
  end  

  def child_of?(name)
    return true if name == @name
    return false unless @parent
    @parent.child_of?(name)
  end

  def base_style
    return self unless @parent
    @parent.base_style
  end
end

class TextStyle < Style
  attr_accessor :bold, :italic, :code

  def to_s
    result = "[Style: #{name}"
    result += 'B' if @bold
    result += 'I' if @italic
    result += 'C' if @code
    result += ']'
  end

  def start(w)
    if @bold
      w.start_bold
    elsif @italic
      w.start_italic
    elsif @code
      w.start_code
    end
  end

  def stop(w)
    if @bold
      w.end_bold
    elsif @italic
      w.end_italic
    elsif @code
      w.end_code
    end    
  end
end


class ParagraphStyle < Style
  attr_accessor :nr_name, :single_line

  def initialize(name, parent=nil, nr_name='', single_line=true)
    super(name, parent)
    @nr_name = nr_name
    @single_line = single_line
  end

  def render(w)
    base = self.base_style
    w.switch_para_style(base.nr_name, base.single_line)
  end
end

class StyleHash < Hash
  def add_style(s)
    self[s.name] = s
  end
end

class Container
  attr_accessor :style, :parent, :contents

  def initialize(style, parent=nil, contents=[])
    @style = style
    @contents = contents
    @parent = parent
  end

  def <<(content)
    @contents << content
  end

  def length
    l = 0
    @contents.each {|kid| l += kid.length}
    l
  end

  def render(w)
    #log "========= rendering #{self.class} size: #{contents.size}"
    #pp contents
    #puts "Rendering:"
    contents.each {|c|  c.render(w)}
  end

  def to_s
    result = "Container #{style}"
    if @contents
      result += @contents.join(' ')      
    end
    result
  end
end

class Span < Container
  attr_accessor :indent

  def render(w)
    l = self.length
    #return if l == 0 and indent == 0
    style.start(w)
    log "Indenting #{indent}"
    w.indent(indent) if indent
    super(w) unless l == 0
    style.stop(w)
  end

  def to_s
    result = " Span: indent #{@indent} #{super} "
  end
end

class Paragraph < Container
  def render(w)
    style.render(w) if style
    super(w)
    w.end_paragraph
  end
end

class Text
  attr_accessor :text

  def initialize(t)
    @text = t
  end

  def render(w)
    text = @text.gsub(/@@/, '\@\@')
    text = text.gsub(/~~/, '\~\~')
    text = text.gsub(/!!/, '\!\!')
    w.text(text)
  end

  def length
    @text.length
  end

  def to_s
    "{{Text: #{text.class} : #{text}}}"
  end
end
