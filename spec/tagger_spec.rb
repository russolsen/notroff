describe TagDirectiveExtractor  do

  let(:paragraph) { Paragraph.new(:body) }
  let(:extractor) { TagDirectiveExtractor.new }

  it 'should not mess with a paragraph with no directive' do
    paragraph.text = 'hello'
    processed = extractor.process([paragraph]).first

    processed.directives.size.should == 0
  end

  it 'should not tag things that just look like tags' do
    paragraph.text = 'hello #(foo'
    processed = extractor.process([paragraph]).first
pp paragraph
    processed.directives.should be_empty
  end

  it 'should deal with start range request' do
    paragraph.text = 'hello ##(foo'
    processed = extractor.process([paragraph]).first

    processed.directives.size.should == 1
    processed.directives.should include(Directive.new(:start_range, 'foo'))
  end

  it 'should deal with end range request' do
    paragraph.text = 'hello ## foo)'
    processed = extractor.process([paragraph]).first

    processed.directives.size.should == 1
    processed.directives.should include(Directive.new(:end_range, 'foo'))
  end

  it 'should deal with include request' do
    paragraph.text = 'hello ##+foo'
    processed = extractor.process([paragraph]).first

    processed.directives.size.should == 1
    processed.directives.should include(Directive.new(:include, 'foo'))
  end

  it 'should deal with exclude request' do
    paragraph.text = 'hello ##   -foo'
    processed = extractor.process([paragraph]).first

    processed.directives.size.should == 1
    processed.directives.should include(Directive.new(:exclude, 'foo'))
  end

  it 'should deal with multiple requests' do
    paragraph.text = 'hello ##+foo -bar (baz'
    processed = extractor.process([paragraph]).first

    processed.directives.size.should == 3
    processed.directives.should include(Directive.new(:include, 'foo'))
    processed.directives.should include(Directive.new(:exclude, 'bar'))
    processed.directives.should include(Directive.new(:start_range, 'baz'))
  end
end

describe Tagger do
  let(:tagger) {Tagger.new}
  let(:extractor) {TagDirectiveExtractor.new}

  def new_paragraph(text)
    Paragraph.new(:text, text)
  end

  def tag_paragraphs(paragraphs)
    tagger.process(extractor.process(paragraphs))
  end

  it 'should tag individual lines' do
    paragraphs = [ new_paragraph('1st line ##+foo'),
                   new_paragraph('2nd line'),
                   new_paragraph('3rd line ##+bar'),
                   new_paragraph('4th line')]

    paragraphs = tag_paragraphs(paragraphs)
    paragraphs.size.should == 4
    paragraphs[0].tags.should include('foo')
    paragraphs[1].tags.should be_empty
    paragraphs[2].tags.should include('bar')
    paragraphs[3].tags.should be_empty
  end

  it 'should tag ranges' do
    paragraphs = [ new_paragraph('1st line ##(foo'),
                   new_paragraph('2nd line'),
                   new_paragraph('3rd line ##foo)'),
                   new_paragraph('4th line')]

    paragraphs = tag_paragraphs(paragraphs)
    paragraphs.size.should == 4
    paragraphs[0].tags.should include('foo')
    paragraphs[1].tags.should include('foo')
    paragraphs[2].tags.should include('foo')
    paragraphs[3].tags.should be_empty
  end

  it 'should tag 2 line paragraph ranges' do
    paragraphs = [ new_paragraph('1st line'),
                   new_paragraph('2nd line'),
                   new_paragraph('3rd line ## (foo'),
                   new_paragraph('4th line ## foo)')]

    paragraphs = tag_paragraphs(paragraphs)
    paragraphs.size.should == 4
    paragraphs[0].tags.should be_empty
    paragraphs[1].tags.should be_empty
    paragraphs[2].tags.should include('foo')
    paragraphs[3].tags.should include('foo')
  end

  it 'should let you add single lines' do
    paragraphs = [ new_paragraph('1st line'),
                   new_paragraph('2nd line ## +extra'),
                   new_paragraph('3rd line')]

    paragraphs = tag_paragraphs(paragraphs)
    paragraphs[0].tags.should be_empty
    paragraphs[1].tags.should include('extra')
    paragraphs[2].tags.should be_empty
  end

  it 'should respect the clear tags directive' do
    paragraphs = [ new_paragraph('1st line ## (foo (bar'),
                   new_paragraph('2nd line ## ! +extra'),
                   new_paragraph('3rd line ## foo) bar)')]

    paragraphs = tag_paragraphs(paragraphs)
    paragraphs[1].tags.should_not include('foo')
    paragraphs[1].tags.should_not include('bar')
    paragraphs[1].tags.should include('extra')
  end

  it 'should let you combine ranges and additive tags' do
    paragraphs = [ new_paragraph('1st line ## (foo (bar'),
                   new_paragraph('2nd line ## -bar'),
                   new_paragraph('3rd line ## -foo +baz'),
                   new_paragraph('4th line ## foo)'),
                   new_paragraph('5th line ## bar)')]

    paragraphs = tag_paragraphs(paragraphs)
    paragraphs[0].tags.should     include('foo')
    paragraphs[0].tags.should     include('bar')

    paragraphs[1].tags.should     include('foo')
    paragraphs[1].tags.should_not include('bar')

    paragraphs[2].tags.should_not include('foo')
    paragraphs[2].tags.should     include('bar')
    paragraphs[2].tags.should     include('baz')


    paragraphs[3].tags.should     include('foo')
    paragraphs[3].tags.should     include('bar')

    paragraphs[4].tags.should_not include('foo')
    paragraphs[4].tags.should     include('bar')
  end
end
