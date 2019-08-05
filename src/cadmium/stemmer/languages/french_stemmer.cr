require "./../stemmer"

module Cadmium
  # Reference : https://snowballstem.org/algorithms/french/stemmer.html
  class FrenchStemmer < Stemmer
    @@french_vowels = ['a', 'e', 'i', 'o', 'u', 'y', 'â', 'à', 'ë', 'é', 'ê', 'è', 'ï', 'î', 'ô', 'û', 'ù']
    @@rv : Range
    @@r1 : Range
    @@r2 : Range

    def self.stem(token : String) : String
      return token if token.size < 3
      rv(token)
      r1(token)
      r2(token)
      step6(step5(step4(step3(step2b(step2a(step1(token.downcase))))))).to_s
    end

    def self.vowel_marking(token : String) : String
      return token unless ('u'.in_set? token || 'i'.in_set? token || 'y'.in_set? token || 'ë'.in_set? token || 'ï'.in_set? token)
      token.gsub(/[aeiouyâàëéêèïîôûù](u)[aeiouyâàëéêèïîôûù]/, 'U')
      token.gsub(/(q)(u)/, 'U')
      token.gsub(/[aeiouyâàëéêèïîôûù](i)[aeiouyâàëéêèïîôûù]/, 'I')
      token.gsub(/[aeiouyâàëéêèïîôûù](y)/, 'Y')
      token.gsub(/(y)[aeiouyâàëéêèïîôûù]/, 'Y')
      token.gsub('ë', "He")
      token.gsub('ï', "Hi")
    end

    def self.rv(token : String) : Range
      if token.starts_with?(/[aeiouyâàëéêèïîôûù]{2}/)
        @@rv = 3..
      else
        token.each_char_with_index do |char, index|
          if @@french_vowels.includes?(char) && index > 0 && index < token.size - 2
            @@rv = index..
          else
            @@rv = Range..index # For the linter
          end
        end
      end
    end

    # def self.r1(token : String) : Range
    #   if !token.index(/(?![aeiouyâàëéêèïîôûù])[a-z]/).nil?
    #   @@r1 = Range token.index[1..](/(?![aeiouyâàëéêèïîôûù])[a-z]/)..
    #   else
    #     @@r1 = Range token.size
    #   end
    # end

    def self.r2(token : String) : Range
    end

    def self.step1(token : String) : String
      #   if token.match(/(ss|i)es$/)
      #     token = token.sub(/(ss|i)es$/, "\\1")
      #   end

      #   if token[-1] == 's' && token[-2] != 's' && token.size > 2
      #     token = token.sub(/s?$/, "")
      #   end

      token
    end

    def self.step2a(token : String) : String
      #   if token.match(/eed$/)
      #     if measure(token[0, token.size - 3]) > 0
      #       return token.sub(/eed$/, "ee")
      #     end
      #   else
      #     result = attempt_replace(token, /(ed|ing)$/, "") do |tok|
      #       if categorize_groups(tok).index('V')
      #         res = attempt_replace_patterns(tok, [
      #           ["at", "", "ate"],
      #           ["bl", "", "ble"],
      #           ["iz", "", "ize"],
      #         ])

      #         if res != tok
      #           return res
      #         else
      #           if ends_with_double_cons(tok) && tok.match(/[^lsz]$/)
      #             return tok.sub(/([^aeiou])\\1$/, "\\1")
      #           end

      #           if measure(tok) == 1 && categorize_chars(tok)[-3, 3]? == "CVC" && tok.match(/[^wxy]$/)
      #             return tok + "e"
      #           end
      #         end

      #         return tok
      #       end

      #       nil
      #     end

      #     return result unless result.nil?
      #   end

      token
    end

    def self.step2b(token : String) : String
      #   categorized_groups = categorize_groups(token)

      #   if token[-1] == 'y' && categorized_groups[0, categorized_groups.size - 1].index('V')
      #     return token.sub(/y$/, "i")
      #   end

      token
    end

    def self.step3(token : String) : String
      #   replace_patterns(token, [["ational", "", "ate"], ["tional", "", "tion"], ["enci", "", "ence"], ["anci", "", "ance"],
      #                            ["izer", "", "ize"], ["abli", "", "able"], ["bli", "", "ble"], ["alli", "", "al"], ["entli", "", "ent"], ["eli", "", "e"],
      #                            ["ousli", "", "ous"], ["ization", "", "ize"], ["ation", "", "ate"], ["ator", "", "ate"], ["alism", "", "al"],
      #                            ["iveness", "", "ive"], ["fulness", "", "ful"], ["ousness", "", "ous"], ["aliti", "", "al"],
      #                            ["iviti", "", "ive"], ["biliti", "", "ble"], ["logi", "", "log"]], 0)
      # end

      # def self.step3(token : String)
      #   replace_patterns(token, [["icate", "", "ic"], ["ative", "", ""], ["alize", "", "al"],
      #                            ["iciti", "", "ic"], ["ical", "", "ic"], ["ful", "", ""], ["ness", "", ""]], 0)
      # end

      # def self.step4(token : String)
      #   replace_regex(token, /^(.+?)(al|ance|ence|er|ic|able|ible|ant|ement|ment|ent|ou|ism|ate|iti|ous|ive|ize)$/, [1], 1) ||
      #     replace_regex(token, /^(.+?)(s|t)(ion)$/, [1, 2], 1) ||
      #     token
      # end

      # def self.step5a(token : String)
      #   m = measure(token.sub(/e$/, ""))
      #   c = categorize_chars(token)

      #   if m > 1 || (m == 1 && c.size > 3 && !(categorize_chars(token)[-4, 3] == "CVC" && token.match(/[^wxy].$/)))
      #     token = token.sub(/e$/, "")
      #   end

      token
    end

    def self.step4(token : String) : String
      #   if measure(token) > 1
      #     return token.sub(/ll$/, "l")
      #   end
      token
    end

    def self.step5(token : String) : String
      token
    end

    def self.step6(token : String) : String
      token
    end

    def self.categorize_groups(token : String)
      token.gsub(/[^aeiouy]+y/, "CV").gsub(/[aeiou]+/, "V").gsub(/[^V]+/, "C")
    end

    def self.categorize_chars(token : String)
      token.gsub(/[^aeiouy]y/, "CV").gsub(/[aeiou]/, "V").gsub(/[^V]/, "C")
    end

    def self.measure(token : String?)
      if !token
        return -1
      end

      categorize_groups(token).sub(/^C/, "").sub(/V$/, "").size / 2
    end

    def self.ends_with_double_cons(token : String)
      !!token.match(/([^aeiou])\\1$/)
    end

    # Attempt to replace a pattern in a word. if a replacement occurs the replacement is returned.
    # Otherwise nil is returned.
    def self.attempt_replace(token : String, pattern : String | Regex, replacement : String)
      result = nil

      if pattern.is_a?(String) && token.ends_with?(pattern)
        result = token.sub(Regex.new(pattern + "$"), replacement)
      elsif pattern.is_a?(Regex) && token.match(pattern)
        result = token.sub(pattern, replacement)
      end

      result
    end

    # Attempt to replae a pattern in a word. If a replacement occurs the replacement is yielded
    # to a block. Otherwise nil is returned
    def self.attempt_replace(token : String, pattern : String | Regex, replacement : String, &block)
      result = attempt_replace(token, pattern, replacement)
      result.nil? ? nil : yield(result.not_nil!)
    end

    # Attempt to replace a list of patterns/replacements on a token for a minimum
    # measure M
    def self.attempt_replace_patterns(token, replacements, measure_threshold = nil)
      replacement = token

      replacements.each do |re|
        if measure_threshold.nil? || measure(attempt_replace(token, re[0].to_s, re[1].to_s)) > measure_threshold.not_nil!
          replacement = attempt_replace(replacement, re[0].to_s, re[2].to_s) || replacement
        end
      end

      replacement
    end

    def self.replace_patterns(token, replacements, measure_threshold = nil)
      attempt_replace_patterns(token, replacements, measure_threshold) || token
    end

    def self.replace_regex(token, regex, include_parts, minimum_measure)
      parts = nil
      result = ""

      if parts = regex.match(token)
        include_parts.each do |i|
          result += parts[i] if !!parts[i]?
        end
      end

      if measure(result) > minimum_measure
        return result
      end

      nil
    end
  end
end
