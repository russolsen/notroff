class String
  # Return the number of leading blanks
  def indent_depth
    /^ */.match(self).to_s.size 
  end
end

class Array
  def find_index( &block )
    each_index do |i|
      return i if block.call( self[i] )
    end
    nil
  end

  # split the array into 3 parts with the middle part
  # being the first continuous section of elements
  # for which the block returns true. The first
  # array is everything before the section and
  # the third is every thing after.
  def section( &block )
    pre = []
    section = []
    post = []

    i = 0
    while ( i < size ) and ( ! block.call( self[i], i ) )
      pre << self[i]
      i += 1
    end

    while ( i < size ) and ( block.call( self[i], i ) )
      section << self[i]
      i += 1
    end

    while ( i < size )
      post << self[i]
      i += 1
    end
    [ pre, section, post ]
  end
end

