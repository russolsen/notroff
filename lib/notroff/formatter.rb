#!/usr/bin/env ruby
require 'pp'
require 'rubygems'

FormatOdtDir = File.dirname(__FILE__)

require "#{FormatOdtDir}/utils"
require "#{FormatOdtDir}/processor"
require "#{FormatOdtDir}/code_processors"
require "#{FormatOdtDir}/odt_renderer"
require "#{FormatOdtDir}/odt_replacer"
require "#{FormatOdtDir}/template_expander"


class Formatter

  OdtSkeleton =  File.join( FormatOdtDir, 'skel.odt' )
  ContentTemplate =  File.join( FormatOdtDir, 'content.xml.erb' )


  def initialize( input, output, options={} )
    @input = input
    @output = output
    @processors = []
    @processors << TextReader.new( @input )
    @processors << CommandProcessor.new
    @processors << ParagraphTypeAssigner.new
    @processors << ProgramOutputInserter.new
    @processors << C1Inserter.new
    @processors << IncInserter.new
    @processors << CodeInserter.new( options )
    @processors << LastOutputInserter.new
    @processors << CodeTagFilter.new
    @processors << CodeTypeRefiner.new
  end

  def process
    result = nil
    @processors.each do |processor|
      result = processor.process( result )
    end
  end
end
   













