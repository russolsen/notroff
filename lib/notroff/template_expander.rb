require 'erb'

TEMPLATE = File.expand_path('../content.xml.erb', __FILE__)

class TemplateExpander < Processor

  def initialize
    @template = ERB.new(File.read(TEMPLATE))
  end

  def process( elements )
    content = elements.join( "\n" )
    @template.result(binding)
  end
end
