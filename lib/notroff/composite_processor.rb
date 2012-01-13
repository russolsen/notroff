class CompositeProcessor
  def initialize(*args)
    @processors = args
  end

  def add_processor(p)
    @processors << p
  end

  def prepend_processor(p)
    @processors = [p] + @processors
  end

  def process(paras=[])
    @processors.each do |processor|
      puts "Applying processor #{processor.class} to #{paras.size} paragraphs"
      paras = processor.process( paras )
      puts "After processor #{processor.class}"
      dump(paras)
    end
    paras
  end

  def dump(array)
    if array.nil?
      puts "Array: #{array}"
    else
      puts "======="
      puts "Array with #{array.size} items:"
      array.each_with_index {|item, i| puts "[#{i}] - #{item}" }
      puts "======="
    end
  end
end













