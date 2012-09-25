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
    print "~~ " if @italic_depth == 1
    @italic_depth -= 1
  end

  def start_code
    print "@@" if @code_depth == 0
    @code_depth += 1
  end

  def end_code
    print "@@ " if @code_depth == 1
    @code_depth -= 1
  end

  def special_style?
    return true unless @para_style ==  :body
    @code_depth > 0 or @italic_depth > 0 or @bold_depth > 0
  end

  def split_text(t)
    return t if t.length < 80
    words = t.split(' ')
  end

  def text(t)
    log "==>Text #{t}"
    if special_style?
      print t
    else
      array = t.split(' ')
      line_len = 0
      array.each do |word|
        print word
        line_len += word.length
        if line_len > 70
          print "\n"
          line_len = 0
        else
          print " "
          line_len += 1
        end
      end
    end
  end
end
