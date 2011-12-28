describe IncludedFilter do
  let(:filter) { IncludedFilter.new }

  let(:paras) do
    paras = %W{ para1 para2 para3 para4 para5}
    paras.map {|p| Text.new(p) }
  end

  it 'should filter out paras that dont have the included tag' do
    paras[1][:included] = paras[3][:included] = true
    new_paras = filter.process(paras)
    new_paras.size.should == 2
    new_paras[0].string.should == 'para2'
    new_paras[1].string.should == 'para4'
  end
end
