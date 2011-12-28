class PUp
  def process(paras)
    paras.map {|p| p.upcase}
  end
end

class PDown
  def process(paras)
    paras.map {|p| p.downcase}
  end
end

describe CompositeProcessor do
  let(:cp) { CompositeProcessor.new() }

  let(:paras) { %W{ para1 para2 para3 } }

  it 'should do nothing with no processors' do
    new_paras = CompositeProcessor.new.process(paras)
    new_paras.should == %W{ para1 para2 para3 }
  end

  it 'should work like a single processor with one subprocessor' do
    cp.add_processor(PUp.new)
    new_paras = cp.process(paras)
    new_paras.should == %W{ PARA1 PARA2 PARA3 }
  end

  it 'should apply several processors in turn' do
    cp.add_processor(PUp.new)
    cp.add_processor(PDown.new)
    new_paras = cp.process(paras)
    new_paras.should == %W{ para1 para2 para3 }
  end
end
