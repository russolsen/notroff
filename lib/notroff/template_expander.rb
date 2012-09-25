require 'rexml/document'



class TemplateExpander < Processor
  PATH = '/office:document-content/office:body/office:text'
  TEMPLATE = File.expand_path('../content.xml', __FILE__)

  def initialize
  end

  def process( content_map )
    doc = REXML::Document.new(File.new(TEMPLATE))
    insert_body(doc, content_map[:body])
    doc.to_s
  end

  def insert_body(doc, body_elements)
    text_element = REXML::XPath.first(doc, PATH)
    n = text_element.elements.size
    n.times {|i| text_element.delete_element(1)}
    body_elements.each {|el| text_element.add_element(el)}
    doc
  end
end
