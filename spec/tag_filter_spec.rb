$: << '../lib'
require 'notroff'
require 'pp'


describe NewTagFilter  do
  let(:tagger) {Tagger.new}
  let(:extractor) {TagDirectiveExtractor.new}

  def new_paragraph(text)
    Paragraph.new(:text, text)
  end

  def tag_paragraphs(paragraphs)
    tagger.process(extractor.process(paragraphs))
  end

  it 'should leave unfiltered lines alone' do
    paragraphs = [ new_paragraph('aaa'),
                   new_paragraph('bbb##(foo'),
                   new_paragraph('ccc'),
                   new_paragraph('ddd##foo)')]

    paragraphs = tag_paragraphs(paragraphs)
    new_paragraphs = NewTagFilter.new.process(paragraphs)
    new_paragraphs.size.should == 4
  end

  it 'should tag individual lines' do
    filter_p = Paragraph.new(:filter)
    filter_p.tag(:filter_tag, 'foo')
    end_filter_p = Paragraph.new(:end_filter)
    end_filter_p.tag(:filter_tag, 'foo')

    paragraphs = [ filter_p,
                   new_paragraph('aaa'),
                   new_paragraph('bbb##(foo'),
                   new_paragraph('ccc'),
                   new_paragraph('ddd##foo)'),
                   end_filter_p,
                   new_paragraph('last line')]

    paragraphs = tag_paragraphs(paragraphs)
    new_paragraphs = NewTagFilter.new.process(paragraphs)
    new_paragraphs.size.should == 4
    new_paragraphs[0].text.should == 'bbb'
    new_paragraphs[1].text.should == 'ccc'
    new_paragraphs[2].text.should == 'ddd'
    new_paragraphs[3].text.should == 'last line'
  end
end
