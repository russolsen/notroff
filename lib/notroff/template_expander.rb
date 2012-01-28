require 'rexml/document'



class TemplateExpander < Processor
  PATH = '/office:document-content/office:body/office:text'
  TEMPLATE = File.expand_path('../content.xml', __FILE__)

  def initialize
  end

  def process( elements )
    puts "reading file: #{TEMPLATE}"
    doc = REXML::Document.new(File.new(TEMPLATE))
    text_element = REXML::XPath.first(doc, PATH)
    n = text_element.elements.size
    puts "deleting #{n} elements"
    n.times {|i| text_element.delete_element(1)}
    puts "ELs: #{elements.size}"
    puts "ELs: #{elements}"
    elements.each {|el| text_element.add_element(el)}
    puts "OUtput: #{doc.to_s}"
    doc.to_s
  end
end
