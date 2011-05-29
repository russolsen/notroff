
class String
  # Return the number of leading blanks
  def indent_depth
    /^ */.match(self).to_s.size
  end
end

module Indent
  def delta_indent_for( desired_indent, line )
    return 0 unless desired_indent
    actual_indent = line.indent_depth
    desired_indent - actual_indent
  end

  def adjust_indent( desired_indent, line )
    delta_indent = delta_indent_for( desired_indent, line )

    return line if delta_indent == 0
    return (" " * delta_indent) + line if delta_indent > 0

    actual_indent = line.indent_depth
    line.sub( ' ' * delta_indent.abs, '' )
  end
end

include Indent


s = '    x=44'
puts delta_indent_for( 2, s )
puts delta_indent_for( 4, s )
puts delta_indent_for( 6, s )
puts '-------'
puts adjust_indent( 0, s) 
puts adjust_indent( 1, s) 
puts adjust_indent( 2, s) 
puts adjust_indent( 3, s) 
puts adjust_indent( 4, s) 
puts adjust_indent( 5, s) 
puts adjust_indent( 6, s) 


