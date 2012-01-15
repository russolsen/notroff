
module Logger
  @verbose = false

  def self.verbose=(value)
    @verbose = value
  end

  def self.log(*args)
    return unless @verbose
    puts args.join(' ')
  end
end
