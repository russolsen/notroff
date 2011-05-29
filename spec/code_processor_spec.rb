$: << '../lib'

require 'pp'
require 'notroff'

describe C1Inserter do

  it 'should leave plain text paragraphs alone' do
    p1 = Paragraph.new( :anything, 'text 1' )
    p2 = Paragraph.new( :anything, 'text 2' )
    code = Paragraph.new( :c1, '', '.c1 some code' )
    paras = [ p1, code, p2 ]
    cp = C1Inserter.new
    output = cp.process(paras)

    output.size.should == 3
    output[0].type.should == :anything
    output[1].type.should == :code
    output[1].text.should == 'some code'
    output[2].type.should == :anything
  end

end

describe ProgramOutputInserter do
  it 'should include the output of a program' do
    p1 = Paragraph.new( :anything, 'text 1' )
    p2 = Paragraph.new( :anything, 'text 2' )
    outinc = Paragraph.new( :output, 'hello.rb' )
    paras = [ p1, outinc, p2 ]
    poi = ProgramOutputInserter.new
    output = poi.process(paras)
    output.size.should == 3
    output[1].type.should == :include
  end

  it 'should include a filter cmd if there is a tag' do
    p1 = Paragraph.new( :anything, 'text 1' )
    p2 = Paragraph.new( :anything, 'text 2' )
    outinc = Paragraph.new( :output, 'hello.rb thetag' )
    paras = [ p1, outinc, p2 ]
    poi = ProgramOutputInserter.new
    output = poi.process(paras)
    output.size.should == 4
    output[1].type.should == :filter
    output[2].type.should == :include
  end

end

describe CodeTagFilter do
  it 'should filter out all but the tagged text' do
    code_paras = []
    5.times {|i| code_paras << Paragraph.new( :code, "code #{i}" ) }
    code_paras[2].text += " ##(thetag"
    code_paras[4].text += " ##thetag)"

    paras = [ Paragraph.new( :filter, 'thetag' ),
              code_paras,
              Paragraph.new( :body, 'whatever' ) ]
    paras.flatten!

    ctf = CodeTagFilter.new
    output = ctf.process(paras)
    output.size.should == 3 + 1 # 3 code + 1 body
    output[0].text.should == 'code 2'
    output[1].text.should == 'code 3'
    output[2].text.should == 'code 4'
  end

  it 'should handle the lone tag form: ##+tag' do
    paras = [ Paragraph.new( :filter, 'thetag' ),
              Paragraph.new( :code, 'no tag' ),
              Paragraph.new( :code, 'this one ##+thetag' ),
              Paragraph.new( :code, 'not this one ##+something else' ),
              Paragraph.new( :body, 'whatever' ) ]

    ctf = CodeTagFilter.new
    output = ctf.process(paras)
    output.size.should == 2
    output[0].text.should == 'this one'
  end
end
