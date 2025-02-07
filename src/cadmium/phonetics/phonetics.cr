require "../tokenizer/aggressive_tokenizer"
require "../i18n/stop_words"

module Cadmium
  abstract class Phonetics
    include Cadmium::I18n::StopWords

    @@tokenizer = Cadmium::AggressiveTokenizer.new

    def self.compare(word1, word2)
      process(word1) == process(word2)
    end

    def self.tokenize_and_phoneticize(word, keep_stops = false)
      phoneticized_tokens = [] of String
      @@tokenizer.tokenize(word).each do |token|
        if keep_stops || @@stop_words.includes?(token) == false
          phoneticized_tokens.push process(token)
        end
      end
      phoneticized_tokens
    end
  end
end
