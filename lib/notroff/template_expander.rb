require 'erb'

class TemplateExpander < Processor

  def initialize( template_text)
    @template = ERB.new( template_text )
  end

  def process( elements )
    content = elements.join( "\n" )
    @template.result(binding)
  end
end
