class CodeReader
  def process(path)
    File.readlines(path).map {|p| Text.new(p.rstrip, :included=>false)}
  end
end
