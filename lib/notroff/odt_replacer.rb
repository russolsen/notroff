require 'pp'
require 'zip/zipfilesystem'
require 'fileutils'


class OdtReplacer < Processor

  def initialize( odt_skeleton_path, output_path )
    @odt_skeleton_path = odt_skeleton_path
    @output_path = output_path
  end

  def process( new_content )
#puts @odt_skeleton_path, @output_path 
    FileUtils.cp( @odt_skeleton_path, @output_path )

    Zip::ZipFile.open( @output_path ) do |zipfile|
      zipfile.file.open("content.xml", "w") do |content|
        content.print( new_content )
      end
    end
  end
end
