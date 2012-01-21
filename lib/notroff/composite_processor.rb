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
      Logger.log "Applying processor #{processor.class} to #{paras.size} paragraphs"
      dump(paras)
      Logger.log
      paras = processor.process( paras )
      Logger.log "After processor #{processor.class}"
      dump(paras)
      Logger.log
    end
    paras
  end

  def dump(data)
    Logger.log "======="
    if data.nil?
      Logger.log "data: nil"
    elsif data.kind_of?(Array)
      Logger.log "data with #{data.size} items:"
      data.each_with_index {|item, i| Logger.log "[#{i}] - #{item.inspect}" }
    else
      Logger.log data
    end
    Logger.log "======="
  end
end













