class BetweenFilter
  def initialize(re1, re2=re1)
    @re1 = re1
    @re2 = re2
  end

  def process(paras)
    state = :before_first
    paras.each do |para|
      if state == :before_first and @re1 =~ para
        para[:included] = true
        state = :after_first
        break if para =~ @re2
      elsif state == :after_first
        para[:included] = true
        break if para =~ @re2
      end
    end
    paras
  end
end

class DefinitionFilter
  def initialize(def_re, include_body=true)
    @def_re = def_re
    @include_body = include_body
  end 

  def process(paras)
    state = :before_def
    end_re = nil
    paras.each do |para|
      Logger.log para, (@def_re =~ para)
      if state == :before_def and @def_re =~ para
        para[:included] = true
        end_re = Regexp.new( "^#{' ' * para.string.indent_depth}end" )
        state = :after_def
      elsif state == :after_def and end_re =~ para.string
        para[:included] = true
        break
      elsif state == :after_def and @include_body
        para[:included] = true
      end
    end
    paras
  end
end

class MethodFilter < DefinitionFilter
  def initialize(method_name, include_body)
    super /^ *def +#{method_name}(\(|$| )/, include_body
  end
end

class ClassFilter < DefinitionFilter
  def initialize(class_name, include_body)
    super /^ *class +#{class_name}(\(|$| )/, include_body
  end
end

class ModuleFilter < DefinitionFilter
  def initialize(module_name, include_body)
    super /^ *module +#{module_name}(\(|$| )/, include_body
  end
end

class EmbeddedRubyProcessor
  def process(paragraphs)
    new_paragraphs = []
    paragraphs.each do |p|
      if p[:type] == :x
        Logger.log p
        results = process_command(p.string)
        new_paragraphs << results if results
      else
        new_paragraphs << p
      end
    end
    new_paragraphs.flatten
  end

  def process_command(ruby_expression)
    Logger.log "Ruby expression: #{ruby_expression}"
    lines = eval(ruby_expression, binding)
  end

  def embed(*filters, &block)
    paras = block.call.map {|line| line.rstrip}
    paras.map! {|p| Text.new(p, :type => :code)}
    Logger.log "EMBED: #{paras}"
    unless filters.empty?
      filters.each {|f| paras = f.process(paras)}
      paras = paras.find_all {|p| p[:included]}
    end
    paras
  end

  def inc(path, *filters)
    embed(*filters) {File.readlines(path)}
  end

  def run(command, *filters)
    embed(*filters) {File.popen(command).readlines}
  end

  def matches(re1, re2=re1)
    BetweenFilter.new(re1, re2)
  end

  def method(name, include_body=true)
    MethodFilter.new(name, include_body)
  end

  def clazz(name, include_body=true)
    ClassFilter.new(name, include_body)
  end

  def mod(name, include_body=true)
    ModuleFilter.new(name, include_body)
  end

  def indent(delta_indent, paragraphs)
    paragraphs.map do |p| 
      if delta_indent > 0
        p.string = (" " * delta_indent) + p.string
      elsif delta_indent < 0
        p.string.sub!( ' ' * delta_indent.abs, '' )
      end
    end
    paragraphs
  end
end
