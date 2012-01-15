describe Formatter do
  let(:formatter) { Formatter.new }

  let(:text_paras) { %W{ para1 para2 para3 para4 para5} }

  it 'should turn join a series of text paragraphs into a single body' do
    new_paras = formatter.process(text_paras)
    new_paras.size.should == 1
    new_paras[0][:type].should == :body
    new_paras[0].string.should == "para1 para2 para3 para4 para5"
  end

  it 'should deal with sticky commands' do
    new_paras = formatter.process( %W{body1 .code code1 code2 .body body2} )
    pp new_paras
    new_paras.size.should == 4
    new_paras[0][:type].should == :body
    new_paras[1][:type].should == :code
    new_paras[2][:type].should == :code
    new_paras[3][:type].should == :body
  end
end
