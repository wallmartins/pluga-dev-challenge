# frozen_string_literal: true

class InputSanitizer
  DANGEROUS_PATTERNS = [
    /ignore (all )?previous( instructions| prompts?)?/i,
    /disregard (previous|prior) (instructions|prompts?)/i,
    /you are now/i,
    /pretend to/i,
    /act as/i,
    /system:/i,
    /instruction:/i,
    /follow these steps/i,
    /output the following/i
  ].freeze

  def self.clean(text)
    return "" unless text

    sanitized = text.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
    sanitized.gsub!(/\u0000/, "")      
    sanitized.gsub!(/<!--.*?-->/m, "")  
    sanitized.gsub!(/[-_*]{4,}/, "\n") 
    sanitized.strip!
    sanitized
  end

  def self.safe?(text)
    return false if text.blank?
    DANGEROUS_PATTERNS.none? { |r| text.match?(r) }
  end
end
