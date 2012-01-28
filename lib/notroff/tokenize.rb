require 'rexml/document'

module Tokenize
  def tokenize_body_text( text )
    text = text.dup
    re = /\~\~.*?\~\~|\@\@.*?\@\@+|\{\{.*?\}\}|!!.*?!!|\^\^.*?\^\^/
    results = []
    until text.empty?
      match = re.match( text )
      if match.nil?
        results << Text.new(text, :type=>:normal)
        text = ''
      else
        unless match.pre_match.empty?
          results << Text.new(match.pre_match, :type=>:normal)
        end
        token =  match.to_s
        results << Text.new(token_text(token), :type=>token_type(token))
        text = match.post_match
      end
    end
    results
  end

  def token_type( token )
    case token
    when /^\~/
      :italic
    when /^\@/
      :code
    when /^\{/
      :footnote
    when /^!/
      :bold
    when /^\^/
      :link
    end
  end

  def parse_link(link_token)
    link_token.split('->').map {|s| s.strip}
  end

  def token_text( token )
    result = token.sub( /^../, '' ).sub( /..$/, '')
    #print "token text for #{token} [[#{result}]]"
    result
  end

  def remove_escapes( text )
    text = text.clone

    results = ''

    until text.empty?
      match = /\\(.)/.match( text )
      if match.nil?
        results << text
        text = ''
      else
        unless match.pre_match.empty?
          results << match.pre_match
        end
        results << match[1]
        text = match.post_match
      end
    end
    results
  end
end
