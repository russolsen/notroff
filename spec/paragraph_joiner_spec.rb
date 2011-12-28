describe BodyParagraphJoiner do
  let(:pj) { BodyParagraphJoiner.new(:body) }

  let(:paras) do
    paras = %W{ para1 para2 para3 para4 para5}
    paras.map {|p| Text.new(p, :type => :body) }
  end

  it 'should turn join a series of similar paragraphs together' do
    new_paras = pj.process(paras)
    new_paras.size.should == 1
    new_paras[0][:type].should == :body
    new_paras[0].string.should == "para1\npara2\npara3\npara4\npara5"
  end

  it 'should turn stop joining on an empty paragraph' do
    paras[2].string = ''
    new_paras = pj.process(paras)
    pp new_paras
    new_paras.size.should == 2
    new_paras[0][:type].should == :body
    new_paras[0].string.should == "para1\npara2"
    new_paras[1][:type].should == :body
    new_paras[1].string.should == "para4\npara5"
  end
end
