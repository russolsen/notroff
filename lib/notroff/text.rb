require 'delegate'

class Text
  attr_accessor :string, :attrs

  def initialize(initial_string, initial_attrs={})
    @string = initial_string.to_str.clone
    @attrs = initial_attrs.clone
  end

  def self.wrap_method(method_name)
    define_method method_name do |*args|
      #print "method: #{method_name} "
      result = @string.send(method_name, *args)
      #puts "Result: #{result}"
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
