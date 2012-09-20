class NRWriter
  attr_reader :para_style

  def initialize
    @bold_depth = 0
    @italic_depth = 0
    @code_depth = 0
    @text_style = :normal
    @single_line = false
  end

  def switch_para_style(new_style, single_line)
    #end_paragraph
    return if new_style == @para_style
    print ".#{new_style}"
    if single_line
      print ' '
    else
      print "\n"
    end
    @para_style = new_style
    @single_line = single_line
  end

  def switch_text_style(new_style)
    log " <<switching to new style #{new_style}>>  "
    return if @text_style == new_style
    if @text_style != :normal
      toggle_text_style(@text_style)
    end
    if new_style != :normal
      toggle_text_style(new_style)
    end
    @text_style = new_style
  end

  def toggle_text_style(style)
    toggle_bold if style == :bold
    toggle_italic if style == :italic
    toggle_code if style == :code    
  end

  def end_paragraph
    puts
    if @single_line
      @para_style = :body
      @single_line = false
    elsif @para_style != :code && @para_style != :listing
      puts
    end
  end

  def indent(n)
    log "indent #{n}"
    print (' ' * n)    
  end

  def start_bold
    print "!!" if @bold_depth == 0
    @bold_depth += 1
  end

  def end_bold
    print "!!" if @bold_depth == 1
    @bold_depth -= 1
  end


  def start_italic
    print "~~" if @italic_depth == 0
    @italic_depth += 1
  end

  def end_italic
    print "~~" if @italic_depth == 1
    @italic_depth -= 1
  end

  def start_code
    print "@@" if @code_depth == 0
    @code_depth += 1
  end

  def end_code
    print "@@" if @code_depth == 1
    @code_depth -= 1
  end

  def text(t)
    log "==>Text #{t}"
    print t
  end
end
