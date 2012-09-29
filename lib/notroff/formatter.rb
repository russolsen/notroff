class Formatter < CompositeProcessor
  def initialize()
    super
    add_processor CommandProcessor.new
    add_processor TypeAssigner.new
    add_processor EmbeddedRubyProcessor.new
    add_processor CodeScrubber.new
    add_processor BodyParagraphJoiner.new
  end
end

class HtmlFormatter < Formatter
  def initialize(input, output)
    super()
    prepend_processor FileReader.new(input)
    add_processor CodeParagraphJoiner.new
    add_processor Grouper.new(:bullet)
    add_processor Grouper.new(:list)
    add_processor HtmlRenderer.new
    add_processor FileWriter.new(output)
  end
end

class DocbookFormatter < Formatter
  def initialize(input, output)
    super()
    prepend_processor FileReader.new(input)
    add_processor CodeParagraphJoiner.new
    add_processor Grouper.new(:bullet)
    add_processor Grouper.new(:list)
    add_processor DocbookRenderer.new
    add_processor OdtReplacer.new(output)
    add_processor OdtReplacer.new(output)
    add_processor FileWriter.new(output)
  end
end

class OdtFormatter < Formatter
  def initialize(input, output)
    super()
    prepend_processor RegularExpressionExcludeFilter.new(/^--.*$/)
    prepend_processor FileReader.new(input)

    add_processor BodyTypeRefiner.new
    add_processor CodeTypeRefiner.new
    add_processor CodeTypeRefiner.new(:listing, :first_listing, :middle_listing, :end_listing)
    add_processor Grouper.new(:bullet)
    add_processor Grouper.new(:list)
    add_processor Grouper.new(:quote)
    add_processor Grouper.new(:attribution)
    add_processor OdtRenderer.new
    add_processor TemplateExpander.new
    add_processor OdtReplacer.new(output)
   end
 end

 class SpecFormatter < Formatter
   def initialize(input, output)
    super()
    prepend_processor RegularExpressionExcludeFilter.new(/^--.*$/)
    prepend_processor FileReader.new(input)
    add_processor BodyTypeRefiner.new
    add_processor CodeTypeRefiner.new
    add_processor CodeTypeRefiner.new(:listing, :first_listing, :middle_listing, :end_listing)
    add_processor Grouper.new(:bullet)
    add_processor Grouper.new(:list)
    add_processor Grouper.new(:quote)
    add_processor Grouper.new(:attribution)
    add_processor SpecRenderer.new
    add_processor FileWriter.new(output)
  end

end













