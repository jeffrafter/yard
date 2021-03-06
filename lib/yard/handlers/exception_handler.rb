class YARD::Handlers::ExceptionHandler < YARD::Handlers::Base
  handles /\Araise(\s|\()/
  
  def process
    return unless owner.is_a?(MethodObject) # Only methods yield
    return if owner.has_tag? :raise

    if klass = statement.tokens.to_s[/^raise[\(\s]*(#{NAMESPACEMATCH})(?:\)|,|\s|(?:\s*(?:\.|\:\:)\s*)?new|$)/, 1]
      owner.docstring.add_tag YARD::Tags::Tag.new(:raise, '', klass)
    end
  end
end