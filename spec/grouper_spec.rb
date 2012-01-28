describe Grouper do
  let(:grouper) { Grouper.new(:code) }
  let(:paras) do
    paras = %W{ para1 para2 para3 para4 para5}
    paras.map {|p| Text.new(p, :type => :code) }
  end

  it 'should group all the code together into a single group' do
    new_paras = grouper.process(paras)
    new_paras.size.should == 1
    group = new_paras.first
    group[:type].should == :group
    group[:kid_type].should == :code
    group[:kids].should == paras
  end
end
