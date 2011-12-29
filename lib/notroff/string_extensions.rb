class String
  # Return the number of leading blanks
  def indent_depth
    /^ */.match(self).to_s.size
  end
end
