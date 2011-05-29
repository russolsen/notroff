$: << '../lib'
require 'notroff'
require 'pp'


describe TextReader do
  it 'should read a file and break it into lines' do
    tr = TextReader.new( 'simple.nr' )
    output = tr.process( false )
    output.size.should == 3
    output[0].should == 'first line'
    output[1].should == 'second line'
    output[2].should == 'third line'
  end
end

describe CommandProcessor do
  it 'should turn an array of strings into Paragraph instances' do
    lines = [ 'line1', '.cmd1', '.cmd2 arg1 arg2' ]
    cp = CommandProcessor.new
    output = cp.process(lines)
    output.size.should == 3
    output[0].type.should == :text
    output[0].text.should == 'line1'
    output[1].type.should == :cmd1
    output[1].text.should == ""
    output[2].type.should == :cmd2
    output[2].text.should == 'arg1 arg2'
  end
end

describe ParagraphTypeAssigner do
  before :each do
    @p1 = Paragraph.new( :text, 'text 1' )
    @p2 = Paragraph.new( :text, 'text 2' )
    @p3 = Paragraph.new( :text, 'text 3' )
    @p4 = Paragraph.new( :text, 'text 4' )
    @p5 = Paragraph.new( :text, 'text 5' )
    @code = Paragraph.new( :code )
    @body = Paragraph.new( :body )
  end

  it 'should leave plain text paragraphs alone' do
    paras = [ @p1, @p2, @p3 ]
    cp = ParagraphTypeAssigner.new
    output = cp.process(paras)
    output.size.should == 3
    paras.each { |p| p.type.should == :text }
  end

  it 'should drop the .body and .code commands' do
    paras = [ @p1, @code, @p2, @p3, @body, @p4 ]
    cp = ParagraphTypeAssigner.new
    output = cp.process(paras)
    output.size.should == 4
  end

  it 'should cascade .body and .code types down' do
    paras = [ @p1, @code, @p2, @p3, @body, @p4 ]
    cp = ParagraphTypeAssigner.new
    output = cp.process(paras)
    output[0].type.should == :body
    output[1].type.should == :code
    output[2].type.should == :code
    output[3].type.should == :body
  end
end

describe CodeTypeRefiner do
  before :each do
    @p1 = Paragraph.new( :text, 'text 1' )
    @p2 = Paragraph.new( :text, 'text 2' )
    @p3 = Paragraph.new( :text, 'text 3' )
    @p4 = Paragraph.new( :text, 'text 4' )
    @p5 = Paragraph.new( :text, 'text 5' )
    @c1 = Paragraph.new( :code )
    @c2 = Paragraph.new( :code )
    @c3 = Paragraph.new( :code )
  end

  it 'should make the type of single lines of code :single_code' do
    paras = [ @p1, @c1, @p3 ]
    cp = CodeTypeRefiner.new
    output = cp.process(paras)
    output.size.should == 3
    output[1].type.should == :single_code
  end

  it 'should make the assign first_code to first line of code, middle_code to middle...' do
    paras = [ @c1, @c2, @c3 ]
    cp = CodeTypeRefiner.new
    output = cp.process(paras)
    output.size.should == 3
    output[0].type.should == :first_code
    output[1].type.should == :middle_code
    output[2].type.should == :end_code
  end
end
