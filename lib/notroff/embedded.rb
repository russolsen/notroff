class SkipFilter
  def initialize(re1)
    @re = re
  end

  def process(paras)
    paras.find_all {|p| p != re}
  end
end

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
    paras = eval(ruby_expression, binding)
    paras.keep_if {|p| p[:included]}
  end

  def embed(type, inc_all=true, lines)
    lines.map! do |line| 
      result = Text.new(line.rstrip, :type => type)
      result[:original_text] = line.rstrip
      result[:included] = inc_all
      result
    end
    lines
  end

  def skip(re, paras)
    paras.each do |para|
      para[:included] = false if (para =~ re)
    end
  end

  def inc(path, inc_all=true, type=:code)
    embed(type, inc_all, File.readlines(path))
  end

  def run(shell_command, type=:code)
    embed(type, File.popen(shell_command).readlines)
  end

  def ex(ruby_command, type=:code)
    embed(type, eval(ruby_command).to_s.split("\n"))
  end

  def stdinc(path, re1=/##A/, re2=/##Z/, type=:code)
    skip(/##X/, between(re1, re2, inc(path, false, type)))
  end

  def between(re1, re2, paras)
    state = :before_first
    paras.each do |para|
      if state == :before_first and re1 =~ para
        state = :after_first
        break if para =~ re2
      elsif state == :after_first
        break if para =~ re2
        para[:included] = true
      end
    end
    paras
  end

  def definition(def_re, include_body, paras)
    state = :before_def
    end_re = nil
    paras.each do |para|
      Logger.log para, (def_re =~ para)
      if state == :before_def and def_re =~ para
        para[:included] = true
        end_re = Regexp.new( "^#{' ' * para.string.indent_depth}end" )
        state = :after_def
      elsif state == :after_def and end_re =~ para.string
        para[:included] = true
        break
      elsif state == :after_def and include_body
        para[:included] = true
      end
    end
    paras
  end


  def meth(method_name, include_body, paras)
    definition(/^ *def +#{method_name}(\(|$| )/, include_body, paras)
  end

=begin
  def clazz(name, include_body=true)
    ClassFilter.new(name, include_body)
  end

  def mod(name, include_body=true)
    ModuleFilter.new(name, include_body)
  end
=end

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
