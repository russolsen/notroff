describe Text do
  let(:t) { Text.new('abc') }

  it 'should be creatable with a string and an attr hash' do
    text = Text.new('abc', :name => 'russ')
    text.string.should == 'abc'
    text.attrs.should == {:name => 'russ'}
  end

  it 'should provide access to the original string' do
    t.string.should == 'abc'
    t.string.class.should == String
  end

  it 'should have a size method like a string' do
    t.size.should == 3
  end

  it 'should support a sub method which should return a Text' do
    new_t = t.sub('b', 'B')
    new_t.class.should == Text
    new_t.string.should == 'aBc'
  end

  it 'should return attributes when you do arithmetic' do
    t[:name] = 'russ'
    new_t = t + "xxx"
    new_t[:name].should == 'russ'
    new_t.string.should == 'abcxxx'
  end

  it 'should support setting and getting attrs via the attrs method' do
    t.attrs[:name] = 'russ'
    t.attrs[:name].should == 'russ'
    t.attrs.should == { :name => 'russ' }
  end

  it 'should support setting and getting attrs via subscripting' do
    t[:name] = 'russ'
    t[:name].should == 'russ'
  end

  it 'should take attrs into account in ==' do
    t_new = Text.new('abc')
    t_new[:name] = 'russ'
    t[:name] = 'russ'

    t.should == t_new

    t_new[:name] = 'bob'
puts "T class: #{t.class}"
puts "Tnew class: #{t_new.class}"
    t.should_not == t_new
  end
end
