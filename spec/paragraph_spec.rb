describe Paragraph do
  it 'should keep its fields straight' do
    d1 = Directive.new(:start, 'foo')
    p = Paragraph.new(:body, 'stuff', 'original_stuff', [d1])
    p.tag :foo
    p.type.should == :body
    p.text.should == 'stuff'
    p.original.should == 'original_stuff'
    p.tagged?(:foo).should be_true
    p.tagged?(:bad).should be_false
    p.directives.should == [d1]
  end

  it 'should support tagging' do
    p = Paragraph.new(:body, 'stuff', 'original_stuff')
    p.tagged?(:foo).should be_false
    p.tag(:foo)
    p.tagged?(:foo).should be_true
  end
end

describe Directive do
  it 'should have a functional ==' do
    d1 = Directive.new(:start, 'foo')
    d2 = Directive.new(:start, 'foo')
    d3 = Directive.new(:end, 'foo')
    d4 = Directive.new(:start, 'bar')

    d1.should == d2
    d1.should_not == d3
    d1.should_not == d4
  end
end

