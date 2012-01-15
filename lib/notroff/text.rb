require 'delegate'

class Text
  attr_accessor :string, :attrs

  def initialize(initial_string, initial_attrs={})
    @string = initial_string.to_str.clone
    @attrs = initial_attrs.clone
  end

  def self.wrap_method(method_name)
    define_method method_name do |*args|
      result = @string.send(method_name, *args)
      return Text.new(result, attrs) if result.kind_of? String
      result
    end
  end

  def self.wrap_methods(method_names)
    method_names.each {|name| wrap_method(name)}
  end

  wrap_methods( String.instance_methods(false) )

  def [](name)
    @attrs[name]
  end

  def []=(name, value)
    @attrs[name] = value
  end

  def ==(other)
    return false unless other.kind_of? Text
    @string == other.string && @attrs == other.attrs
  end

  def clone
    Text.new(string, attrs)
  end

  def to_str
    #puts "To string: #{@string.class} #{@string}"
    @string
  end

  def to_s
    @string
  end

  def inspect
    "#{@string.inspect} :: #{@attrs.inspect}"
  end
end

class String
  def to_text
    Text.new(self)
  end

  alias_method :old_double_equals, :'=='

  def ==(other)
    return self == other.string if other.kind_of?(Text)
    old_double_equals(other)
  end
end
