
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

  def render(w)
    w.toggle_bold if @bold
    w.toggle_code if @code
    w.toggle_italic if @italic
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

class Container
  attr_accessor :style, :parent, :contents

  def initialize(style, parent=nil, contents=[])
    @style = style
    @contents = contents
  end

  def <<(content)
    @contents << content
  end

  def render(w)
    #puts "========= rendering #{self.class} size: #{contents.size}"
    #pp contents
    #puts "Rendering:"
    contents.each {|c|  c.render(w)}
  end
end

class Span < Container
  attr_accessor :indent

  def render(w)
    style.render(w)
    w.indent(@indent) if @indent
    super(w)
    style.render(w)
  end
end

class Paragraph < Container
  def render(w)
    style.render(w)
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
    w.text(@text)
  end

  def to_s
    "{{Text: #{text.class} : #{text}}}"
  end
end
