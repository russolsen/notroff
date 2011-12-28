
class FileProcessor
  def initialize(path)
    @path = path
  end
end

class FileReader < FileProcessor
  def process(ignored)
    paras = File.readlines(@path)
    paras.map! {|p| p.rstrip}
  end
end

class FileWriter < FileProcessor
  def process(output)
    File.open(@path, 'w') {|f| f.write(output)}
  end
end
