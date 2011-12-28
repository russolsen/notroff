class String
  def to_text
    Text.new(self)
  end

  alias_method :old_double_equals, :'=='

  def ==(other)
    return self == other.string if other.kind_of?(Text)
    old_double_equals(other)
  end

  # Return the number of leading blanks
  def indent_depth
    /^ */.match(self).to_s.size
  end
end
