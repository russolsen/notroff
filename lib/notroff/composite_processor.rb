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
      puts "Now have #{paras.size} paragraphs" if paras
      p paras
      puts "========="
    end
    paras
  end
end













