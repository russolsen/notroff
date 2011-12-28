describe TypeAssigner do
  let(:ta) { TypeAssigner.new }
  let(:paras) do
    paras = %W{ para1 para2 para3 para4 para5}
    paras.map {|p| Text.new(p, :type => :text) }
  end

  it 'should turn plain text paras into body paras' do
    new_paras = ta.process(paras)
    new_paras.each {|p| p[:type].should == :body}
  end

  it 'should make .code commands sticky while droping the code command' do
    paras[0] = Text.new( '', :type => :code)
    new_paras = ta.process(paras)
    new_paras.size.should == 4
    new_paras.each {|p| p[:type].should == :code}
  end

  it 'should make switch between .code and .body commands' do
    paras[0] = Text.new( '', :type => :code)
    paras[3] = Text.new( '', :type => :body)
    new_paras = ta.process(paras)
    new_paras.size.should == 3
    new_paras[0][:type].should == :code
    new_paras[1][:type].should == :code
    new_paras[2][:type].should == :body
  end

  it 'should know that section and code1 are automatically followed by body' do
    paras[0] = Text.new( 'section!', :type => :sec)
    paras[2] = Text.new( 'code1!', :type => :code1)
    new_paras = ta.process(paras)
    new_paras[0][:type].should == :sec
    new_paras[1][:type].should == :body
    new_paras[2][:type].should == :code
    new_paras[3][:type].should == :body
  end
end
