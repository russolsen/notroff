class Processor
end

class Paragraph
  attr_accessor :type, :text, :original

  def initialize( type, text='', original='' )
    @type = type
    @text = text
    @original = original
  end

  def self.copy( other )
    self.new( other.type, other.text, other.original )
  end

  def blank?
    return true if @text.nil?
    @text !~ /\S/
  end

  def append_text( more_text )
    @text += ( ' ' + more_text)
  end

  def to_s
    "Paragraph: [#{type}] [[#{text}]]"
  end
end

class TextPrinter
  def process( text )
    puts text
  end
end

class FileWriter
  def initialize(output_file)
    @output_file = output_file
  end

  def process(content)
    File.open(@output_file, 'w') do |f|
      f.print(content.to_s)
    end
  end
end

class Printer
  def process( paragraphs )
    paragraphs.each {|p| puts "#{p.type}: #{p.text}"}
  end
end

class TextReader < Processor

  def initialize( path )
    @path = path
  end

  def process( ignored )
    lines = File.open( @path ).readlines
    lines.map! { |line| line.rstrip }
    lines
  end

end

class CommandProcessor

  def process( lines )
    paragraphs = []
    lines.each do |line|
      cmd, text = parse_line( line )

      if cmd.empty?
        paragraphs << Paragraph.new( :text, text, line )
      else
        cmd_symbol = cmd.sub(/^./, '').to_sym
        paragraphs << Paragraph.new( cmd_symbol, text, line )
      end
    end
    paragraphs
  end

  def parse_line( line )
    match_data = /^(\.\w+ ?)(.*)/.match(line)
    if match_data
      cmd = match_data[1].strip
      text = match_data[2]
    else
      cmd = ''
      text = line
    end
    #puts "parse: cmd: [[#{cmd}]] text: [[#{text}]]"
    [ cmd.strip, text ]
  end
end

class ParagraphTypeAssigner

  def process( paragraphs )
puts "type assigner"
p paragraphs
    processed_paragraphs = []

    current_type = :body

    paragraphs.each do |paragraph|  
      type = paragraph.type  
      if (type == :body) or (type == :code) or (type == :quote)
        current_type = type

      elsif type == :text
        new_p = Paragraph.copy( paragraph )
        new_p.type = current_type
        processed_paragraphs << new_p

      #elsif type == :quote         # Quick hack
      #  new_p = Paragraph.copy( paragraph )
      #  new_p.type = :body
      #  processed_paragraphs << new_p

      else
        processed_paragraphs << paragraph
      end

      current_type = :body if [ :section, :title, :code1 ].include?(type)
    end
p processed_paragraphs
    processed_paragraphs
  end
end

class CodeTypeRefiner
  def process( paragraphs )
#puts "======== code type refiner ======="
#pp paragraphs
    processed_paragraphs = []

    previous_type = nil
   
    paragraphs.each_with_index do |paragraph, i|
      type = paragraph.type
      previous_type = ( paragraphs.first == paragraph) ? nil : paragraphs[i-1].type
      next_type = ( paragraphs.last == paragraph) ? nil : paragraphs[i+1].type
      new_type = code_type_for( previous_type, type, next_type )
      new_p = Paragraph.copy( paragraph )
      new_p.type = new_type
      processed_paragraphs << new_p
    end
    processed_paragraphs
  end

  def code_type_for( previous_type, type, next_type )
    if type != :code
      new_type = type
      
    elsif previous_type == :code and next_type == :code
      new_type = :middle_code

    elsif previous_type == :code
      new_type = :end_code

    elsif next_type == :code
      new_type = :first_code

    else
      new_type = :single_code
    end

    #puts "prev: #{previous_type} type: #{type} next: #{next_type} result: #{new_type}"
    new_type
  end
end

class SimilarParagraphJoiner
  def initialize(target_type)
    @target_type = target_type
  end

  def process( paragraphs )
    processed_paragraphs = []
    new_p = nil
puts "**** before processing #{paragraphs.size}"
    paragraphs.each do |paragraph|
      if paragraph.type  != @target_type
        processed_paragraphs << new_p if new_p
        new_p = nil
        processed_paragraphs << paragraph

      elsif new_p
        new_p.text += "\n"
        new_p.text += paragraph.text

      else
        new_p = paragraph 
      end
    end
    processed_paragraphs << new_p if new_p
    puts "**** after processing #{paragraphs.size}"
    processed_paragraphs.each {|p| puts p}
    processed_paragraphs
  end
end

class TextParagraphJoiner
  def process( paragraphs )
    processed_paragraphs = []

    new_p = nil

    paragraphs.each do |paragraph|
      if (paragraph.type  != :body) and (paragraph.type  != :quote)
        processed_paragraphs << new_p if new_p
        new_p = nil
        processed_paragraphs << paragraph

      elsif paragraph.blank?
        processed_paragraphs << new_p if new_p
        new_p = nil

      elsif new_p
        new_p.append_text( paragraph.text )

      else
        new_p = paragraph 
      end
    end
    processed_paragraphs << new_p if new_p
    processed_paragraphs
  end
end


