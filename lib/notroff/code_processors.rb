require 'stringio'

class CodeInserter

  def initialize( options )
    @include_filename = options[:fn]
  end

  def process( paragraphs )
    new_paragraphs = []
    paragraphs.each do |p|
      if p.type == :include
        code_lines = read_code( p.text )
        code_lines = code_lines.map {|line| Paragraph.new( :code, line ) }
        new_paragraphs << code_lines
        if @include_filename
          new_paragraphs << Paragraph.new( :body, "FILE: #{p.text}" )
        end
      else
        new_paragraphs << p
      end
    end
    new_paragraphs.flatten!
    new_paragraphs
  end

  def read_code( text )
    path = text.strip
    lines = File.readlines( path )
    lines.map { |line| cleanup(line) }
  end

  def cleanup( line )
    line.rstrip
  end

end

class CodeTagFilter
  def process( paragraphs )

puts "============= before tag filter ============="
#pp paragraphs

    new_paragraphs = []

    i = 0
    while i < paragraphs.size 
      p = paragraphs[i]
puts "::paragraph:"
pp p
      if p.type != :filter
        new_paragraphs << p
      else
        tag, indent = p.text.split
        tag.strip!
        indent = indent ? indent.to_i : 0
        prefix, code, postfix = paragraphs.section do |paragraph, j|
          j > i and paragraph.type == :code
        end
        code = filter_paragraphs( code, tag, indent )
        paragraphs = prefix + code + postfix
      end
      i += 1
    end
    raise "nothing found for #{tag}" if new_paragraphs.empty?
#puts "paragraphs --- After Tag filter----------"
#pp new_paragraphs
#puts "==============="
    new_paragraphs
  end

  def filter_paragraphs( paragraphs, tag, indent )
    single_pattern = Regexp.new( '##.*\+' + tag + '$')
    begin_pattern = Regexp.new( '##.*\(' + tag + '$')
    end_pattern = Regexp.new( '##.*' + tag + '\)' + '$')
    omit_pattern = Regexp.new( '##.*--' + tag + '$')
   
    results = []
    state = :ignore
    paragraphs.each do |p|
      case state
      when :ignore
        if p.text =~ single_pattern
          results << p
        elsif p.text =~ begin_pattern
          results << p
          state = :inside_run
        elsif p.text =~ end_pattern
          raise "End for #{tag} found before beginning"
        end

      when :inside_run
        if p.text =~ end_pattern
          results << p
          state = :ignore
        elsif p.text =~ begin_pattern
          raise "Begin for #{tag} found inside run"
        else
          results << p
        end
      end
    end
    raise "No end tag for #{tag}" if state == :inside_run
    results.delete_if { |p| p.text =~ omit_pattern }
    raise "No lines selected for tag #{tag}" if results.empty?
    delta_indent = delta_indent_for( indent, results.first.text )
    results.each { |p| cleanup(p, delta_indent) }
  end

  def delta_indent_for( desired_indent, line )
#puts "Desired indent: #{desired_indent} [#{line}]"
    return 0 unless desired_indent
    actual_indent = line.indent_depth
#puts "###delta indent for #{desired_indent - actual_indent} [#{line}]"
    desired_indent - actual_indent
  end

  def adjust_indent( delta_indent, line )
    #puts "adjust: #{delta_indent} [#{line}]"
    result = xx_adjust_indent( delta_indent, line )
    #puts "  result = [#{result}]"
    result
  end

  def xx_adjust_indent( delta_indent, line )
    return line if delta_indent == 0
    return (" " * delta_indent) + line if delta_indent > 0

    actual_indent = line.indent_depth
    line.sub( ' ' * delta_indent.abs, '' )
  end


  def cleanup( p, delta_indent )
    p.text.sub!( /##.*/, '' )
    p.text.rstrip!
    p.text = adjust_indent( delta_indent, p.text )
  end

end

class ProgramOutputInserter

  def process( paragraphs )

    new_paragraphs = []

    paragraphs.each do |p|
      unless p.type == :output
        new_paragraphs << p
        next
      end
      ruby_file, tag = p.text.split
      status = system( "ruby #{ruby_file} >#{ruby_file}.out" )
      raise "Command #{ruby_file} failed" unless status
      new_paragraphs << Paragraph.new( :filter, tag, p.original ) if tag
      new_paragraphs << Paragraph.new( :include, "#{ruby_file}.out" )
    end
    new_paragraphs
  end
end

class IncInserter

  def process( paragraphs )
    new_paragraphs = []

    paragraphs.each do |p|
      unless p.type == :inc
        new_paragraphs << p
        next
      end
      file, tag, indent = p.text.split
      raise "No file specificed" if file.empty?
      new_paragraphs << Paragraph.new( :filter, tag + " #{indent}"  ) if tag
      new_paragraphs << Paragraph.new( :include, file  )
    end
#puts "========= Inc Inserter ========"
#pp new_paragraphs
#puts "============"
    new_paragraphs
  end
end

class C1Inserter 

  def process( paragraphs )
    new_paragraphs = []

    paragraphs.each do |p|
      unless p.type == :c1
        new_paragraphs << p
        next
      end
      new_paragraphs << Paragraph.new( :code, p.original.sub(/^..../, '') )
    end
    new_paragraphs
  end
end

class LastOutputInserter

  def process( paragraphs )

    new_paragraphs = []

    paragraphs.each_with_index do |p, i|
      unless [:lastputs, :lastpp, :lastout].include?(p.type)
        new_paragraphs << p
        next
      end

      code_start = start_index_of_previous_code_block( paragraphs, i )
      code_end = end_index_of_previous_code_block( paragraphs, i )
      code = join_text( paragraphs[code_start..code_end] )

      result = nil

      if p.type == :lastpp
        result = output_of { pp eval( code ) }

      elsif p.type == :lastputs
        result = output_of { puts( eval( code ) ) }

      elsif p.type == :lastout
        result = output_of { eval( code ) }
      else
        raise "Dont know what to do with #{p.type}"
      end
      lines = result.split("\n")
      new_paragraphs << lines.map {|line| Paragrpah.new( :code, line ) }
    end
    new_paragraphs.flatten
  end

  def output_of( &block )
    io = StringIO.new
    $stdout = io
    begin
      block.call
    ensure
      $stdout = STDOUT
    end
    io.string
  end

  def print_code_result( method, code )
    result = eval( code )
    io = StringIO.new
    io.send( method, result )
    io.string
  end

  def end_index_of_previous_code_block( paragraphs, starting_index)
    i = starting_index
    while i >= 0
      return i if paragraphs[i].type == :code
      i -= 1
    end
    nil
  end

  def start_index_of_previous_code_block( paragraphs, starting_index )
    i = end_index_of_previous_code_block( paragraphs, starting_index )
    return nil unless i
    while i >= 0
      return i+1 unless paragraphs[i].type == :code
      i -= 1
    end
    0
  end

  def join_text( paragraphs )
     ( paragraphs.map {|p| p.text} ).join("\n")
  end

end



