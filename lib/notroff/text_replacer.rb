#require 'rexml/document'
require 'pp'
#require 'zip/zipfilesystem'
#require 'fileutils'
#require 'erb'

FormatOdtDir = File.dirname(__FILE__)

require "#{FormatOdtDir}/utils"
require "#{FormatOdtDir}/processor"
require "#{FormatOdtDir}/code_processors"
require "#{FormatOdtDir}/odt_renderer"
require "#{FormatOdtDir}/odt_replacer"
require "#{FormatOdtDir}/template_expander"


class Editor

  def initialize( input, output )
    @input = input
    @output = output
    @processors = []
    @processors << TextReader.new( @input )
    @processors << CommandProcessor.new
    @processors << ParagraphTypeAssigner.new
    @processors << ProgramOutputInserter.new
    @processors << C1Inserter.new
    @processors << IncInserter.new
    @processors << CodeInserter.new
    @processors << LastOutputInserter.new
    @processors << CodeTagFilter.new
    @processors << CodeTypeRefiner.new
    @processors << OdtRenderer.new
    @processors << TemplateExpander.new( File.read( ContentTemplate ) )
    @processors << OdtReplacer.new( OdtSkeleton, @output )
  end

  def process
    result = nil
    @processors.each do |processor|
      result = processor.process( result )
    end
  end
end
   

f = Editor.new( ARGV[0], ARGV[1]  )
f.process


















