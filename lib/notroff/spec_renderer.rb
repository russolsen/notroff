require 'rexml/document'
require 'pp'


class SpecRenderer < Processor
  include Tokenize
  include REXML

  @@footnote_number = 1

  def initialize
    @last_code = false
  end

  def process( paragraphs )
    elements = []
    paragraphs.each do |paragraph|
      new_element = format( paragraph )
      elements << new_element if new_element
    end
    "require 'utils/utils'\n\ndescribe 'foo' do\n\n#{elements.join}\nend\n"
  end

  def format( para )
    Logger.log "Format: #{para.inspect}"
    type = para[:type]
    text = para

    this_code = code_type?(type)


    if @last_code and this_code
      ret =  "#{para}\n"

    elsif @last_code
      ret =  "##FOO_B\n  end\n"

    elsif this_code
      ret = "\n  it 'should foo' do\n##FOO_A\n#{para}\n"

    else
      ret = nil
    end

    @last_code = this_code
    ret
  end

  def code_type?( type )
    [ :first_code, :middle_code, :end_code, :single_code,
      :listing, :first_listing, :middle_listing, :end_listing ].include?(type)
  end
end
