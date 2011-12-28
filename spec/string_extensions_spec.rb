describe String do
  it 'should let you turn a string into a Text' do
    t = 'abc'.to_text
    t.class.should == Text
    t.string.should == 'abc'
    t.attrs.should == {}
  end

  it 'should still have a working ==' do
    s = 'abc'
    s.should == 'abc'
    s.should_not == 'xxx'
    s.should_not == 123
    s.should_not == nil
  end

  it 'should be == to Text instances with the same string' do
    s = 'abc'
    s.should == Text.new('abc')
    s.should_not == Text.new('xxx')
  end
end
