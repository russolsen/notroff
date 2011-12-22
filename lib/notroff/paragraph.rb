require 'set'

class Directive
  attr_accessor :name, :type

  def initialize(type, name)
    @type = type
    @name = name
  end

  def ==(other)
    return false unless other.kind_of?(self.class)
    @type == other.type && @name == other.name
  end
end

class Paragraph
  attr_accessor :type, :text, :original, :directives, :tags

  def self.with_tags(type, tags)
    p = new(type)
    p.tags = p.tags.merge(tags)
    p
  end

  def initialize( type, text='', original='', directives=[], tags={} )
    @type = type
    @text = text
    @original = original
    @directives = directives
    @tags = tags
  end

  def self.copy( o )
    self.new( o.type, o.text.clone, o.original.clone, o.directives.clone, o.tags.clone )
  end

  def blank?
    return true if @text.nil?
    @text !~ /\S/
  end

  def append_text( more_text )
    @text += ( ' ' + more_text)
  end

  def add_directive(*directives)
    @directives += directives
  end

  def del_directive(*directives)
    @directives -= directives
  end

  def directive?(type, name)
    @directives.include?(Directive.new(type, name))
  end

  def remove_tag(the_tag)
    @tags.delete(the_tag)
  end

  def tag(name, tag_value=true)
    @tags[name] = tag_value
  end

  def tagged?(name)
    @tags.include?(name)
  end

  def tag_value(name)
    @tags[name]
  end

  def to_s
    "Paragraph: [#{type}] #{tags.inspect} #{directives.inspect} [[#{text}]]"
  end
end
