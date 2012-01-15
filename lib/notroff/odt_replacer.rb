require 'pp'
require 'zip/zipfilesystem'
require 'fileutils'

SKEL = File.expand_path('../skel.odt', __FILE__)

class OdtReplacer < Processor

  def initialize( output_path )
    @output_path = output_path
  end

  def process( new_content )
    FileUtils.cp( SKEL, @output_path )

    Zip::ZipFile.open( @output_path ) do |zipfile|
      zipfile.file.open("content.xml", "w") do |content|
        content.print( new_content )
      end
    end
  end
end
