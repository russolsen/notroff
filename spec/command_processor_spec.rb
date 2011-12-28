describe CommandProcessor do
  let(:cp) { CommandProcessor.new }

  it 'should turn a plain line of text into a .text command' do
    lines = [ 'line 1', 'line 2' ]
    new_lines = cp.process(lines)
    new_lines.size.should == 2
    new_lines[0].string.should == 'line 1'
    new_lines[1].string.should == 'line 2'
    new_lines[0][:type].should == :text
    new_lines[1][:type].should == :text
    new_lines[0][:original_text].should == 'line 1'
    new_lines[1][:original_text].should == 'line 2'
  end
end
