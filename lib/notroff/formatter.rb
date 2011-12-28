class Formatter < CompositeProcessor
  def initialize()
    super
    add_processor CommandProcessor.new
    add_processor TypeAssigner.new
    add_processor EmbeddedRubyProcessor.new
    add_processor BodyParagraphJoiner.new
  end
end

class HtmlFormatter < Formatter
  def initialize(input, output)
    super()
    prepend_processor FileReader.new(input)
    add_processor CodeParagraphJoiner.new
    add_processor HtmlRenderer.new
    add_processor FileWriter.new(output)
  end
end













